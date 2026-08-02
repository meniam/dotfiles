#!/usr/bin/env bash
# Install Yazi and its locked plugins, plus Ouch and RAR/UnRAR for archives.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"
detect_os

# The sanity check runs against an empty config directory on purpose. Yazi
# loads the configuration before it prints its version, and a theme.toml naming
# a flavor that `ya pkg install` has not fetched yet stops it on a "Press
# <Enter> to continue with preset settings..." prompt: an endless wait wherever
# stdin is a terminal, and a non-zero exit that would order a fresh download of
# a perfectly working binary wherever it is not.
yazi_is_usable=false
if command -v yazi >/dev/null 2>&1; then
  yazi_probe_home="$(mktemp -d)"
  YAZI_CONFIG_HOME="$yazi_probe_home" yazi --version >/dev/null 2>&1 </dev/null &&
    yazi_is_usable=true
  rm -rf "$yazi_probe_home"
fi

if [ "$OS" = "linux" ] && [ "$yazi_is_usable" = false ]; then
  case "$(uname -m)" in
    x86_64|amd64) target="x86_64-unknown-linux-musl" ;;
    aarch64|arm64) target="aarch64-unknown-linux-musl" ;;
    *) die "Unsupported architecture: $(uname -m)" ;;
  esac

  command -v unzip >/dev/null 2>&1 || { $SUDO apt-get update -y && apt_install unzip; }
  bindir="$HOME/.local/bin"
  mkdir -p "$bindir"
  temporary_dir="$(mktemp -d)"
  trap 'rm -rf "$temporary_dir"' EXIT HUP INT TERM
  archive="$temporary_dir/yazi.zip"
  url="https://github.com/sxyazi/yazi/releases/latest/download/yazi-${target}.zip"
  step "Downloading Yazi for $target" "*"
  curl -fL --connect-timeout 15 --retry 2 "$url" -o "$archive" || die "Unable to download Yazi."
  unzip -q "$archive" -d "$temporary_dir" || die "Unable to unpack Yazi."
  for binary in yazi ya; do
    source_binary="$(find "$temporary_dir" -type f -name "$binary" 2>/dev/null | head -1)"
    [ -n "$source_binary" ] || die "The release does not contain '$binary'."
    install -Dm755 "$source_binary" "$bindir/$binary"
  done
  rm -rf "$temporary_dir"
  trap - EXIT HUP INT TERM
fi

# GNU parallel prints a request to cite it academically on every run until this
# file exists, which lands in the stderr of every script that calls it.
if command -v parallel >/dev/null 2>&1 && [ ! -f "$HOME/.parallel/will-cite" ]; then
  step "Silencing the GNU parallel citation notice" "*"
  mkdir -p "$HOME/.parallel"
  : >"$HOME/.parallel/will-cite"
fi

# pydf is an APT-only package, so its configuration is meaningless on macOS.
# Stow links the whole payload regardless, and this drops the dangling link it
# leaves behind. Only a link into this repository is removed.
if [ "$OS" = "mac" ] && [ -L "$HOME/.pydfrc" ]; then
  case "$(readlink "$HOME/.pydfrc")" in
    *"/modules/fs/config/.pydfrc") rm -f "$HOME/.pydfrc" ;;
  esac
fi

if command -v ya >/dev/null 2>&1; then
  step "Installing locked Yazi plugins and flavors" "*"
  # `ya pkg install` prints raw git fetch/checkout output per plugin with no
  # quiet flag; keep it captured and only surface it if the install fails.
  pkg_log="$(mktemp)"
  trap 'rm -f "$pkg_log"' EXIT HUP INT TERM
  if ! ya pkg install >"$pkg_log" 2>&1 </dev/null; then
    warn "Yazi plugins could not be installed automatically."
    cat "$pkg_log" >&2
  fi
  rm -f "$pkg_log"
  trap - EXIT HUP INT TERM
else
  warn "The 'ya' companion binary is unavailable; plugin installation is skipped."
fi

# mermaid-ascii turns the ```mermaid fences in a Markdown file into ASCII art
# for the vendored myazin-mermaid-glow previewer. Neither Homebrew nor APT
# packages it, and building it from source would pull in a Go toolchain nothing
# else here needs, so take the upstream release binary the way Yazi and Ouch do.
# It is optional: without it the previewer leaves the fences as source.
if ! command -v mermaid-ascii >/dev/null 2>&1; then
  case "$OS" in
    mac) release_os="Darwin" ;;
    *) release_os="Linux" ;;
  esac
  case "$(uname -m)" in
    x86_64|amd64) release_arch="x86_64" ;;
    aarch64|arm64) release_arch="arm64" ;;
    *) release_arch="" ;;
  esac

  if [ -z "$release_arch" ]; then
    warn "mermaid-ascii is not published for $(uname -m); mermaid diagrams will preview as source."
  else
    temporary_dir="$(mktemp -d)"
    trap 'rm -rf "$temporary_dir"' EXIT HUP INT TERM
    archive="$temporary_dir/mermaid-ascii.tar.gz"
    url="https://github.com/AlexanderGrooff/mermaid-ascii/releases/latest/download/mermaid-ascii_${release_os}_${release_arch}.tar.gz"

    step "Downloading mermaid-ascii for ${release_os}/${release_arch}" "*"
    if ! curl -fL --connect-timeout 15 --retry 2 "$url" -o "$archive"; then
      warn "mermaid-ascii could not be downloaded; mermaid diagrams will preview as source."
    elif ! tar -xzf "$archive" -C "$temporary_dir"; then
      warn "The mermaid-ascii archive could not be unpacked; mermaid diagrams will preview as source."
    else
      source_binary="$(find "$temporary_dir" -type f -name mermaid-ascii -perm -u+x 2>/dev/null | head -1)"
      if [ -z "$source_binary" ]; then
        warn "The mermaid-ascii release does not contain the expected binary."
      else
        # BSD install(1) on macOS has no -D, so create the directory separately
        # instead of reusing the `install -Dm755` calls above, which are Linux only.
        mkdir -p "$HOME/.local/bin"
        mv "$source_binary" "$HOME/.local/bin/mermaid-ascii"
        chmod 755 "$HOME/.local/bin/mermaid-ascii"
      fi
    fi
    rm -rf "$temporary_dir"
    trap - EXIT HUP INT TERM
  fi
fi

# Tag of the newest release of a GitHub repository, read from the redirect of
# /releases/latest instead of from the API, which rate-limits an unauthenticated
# caller to sixty requests an hour per address.
github_latest_tag() {
  local resolved
  resolved="$(curl -fsSLI -o /dev/null -w '%{url_effective}' --connect-timeout 15 --retry 2 \
    "https://github.com/$1/releases/latest")" || return 1
  case "$resolved" in
    */releases/tag/*) printf '%s' "${resolved##*/}" ;;
    *) return 1 ;;
  esac
}

# Fetch an upstream release artifact and put the executable it carries into
# ~/.local/bin. Failure is returned rather than fatal: every caller installs a
# tool APT could not provide, and losing one must not discard the whole module.
install_release_binary() {
  local url="$1" binary="$2" work archive source_binary status=0
  work="$(mktemp -d)" || return 1
  archive="$work/${url##*/}"

  if curl -fL --connect-timeout 15 --retry 2 "$url" -o "$archive"; then
    case "$archive" in
      *.tar.xz) tar -xJf "$archive" -C "$work" || status=1 ;;
      *.tar.gz) tar -xzf "$archive" -C "$work" || status=1 ;;
      *.zip) unzip -qo "$archive" -d "$work" || status=1 ;;
      # A release that publishes the bare executable: the download is the binary.
      *) mv "$archive" "$work/$binary" || status=1 ;;
    esac
  else
    status=1
  fi

  if [ "$status" -eq 0 ]; then
    source_binary="$(find "$work" -type f -name "$binary" 2>/dev/null | head -1)"
    if [ -n "$source_binary" ]; then
      install -Dm755 "$source_binary" "$HOME/.local/bin/$binary" || status=1
    else
      status=1
    fi
  fi

  rm -rf "$work"
  return "$status"
}

# duckdb, typst, watchexec, sd, and choose reach Debian and Ubuntu late, so the
# installer skips them wherever APT has no candidate, and the bat those releases
# do package predates the themes this module configures. Upstream publishes each
# of them as a static binary, so take the release the way Yazi and Ouch already do.
if [ "$OS" = "linux" ]; then
  case "$(uname -m)" in
    x86_64|amd64)
      musl_target="x86_64-unknown-linux-musl"
      duckdb_target="amd64"
      choose_asset="choose-x86_64-unknown-linux-musl"
      ;;
    aarch64|arm64)
      musl_target="aarch64-unknown-linux-musl"
      duckdb_target="arm64"
      # Upstream builds `choose` against musl for x86_64 only.
      choose_asset="choose-aarch64-unknown-linux-gnu"
      ;;
    *)
      musl_target=""
      duckdb_target=""
      choose_asset=""
      ;;
  esac

  if [ -z "$musl_target" ]; then
    warn "No upstream release covers $(uname -m); duckdb, typst, watchexec, sd, and choose stay unavailable, and bat keeps whatever APT packaged."
  else
    # tar shells out to `xz`, which a minimal installation may not carry, and
    # both watchexec and typst publish their Linux builds as .tar.xz only.
    if ! command -v xz >/dev/null 2>&1; then
      warn "xz is missing; watchexec and typst cannot be unpacked from their upstream releases."
    else
      for release_tool in watchexec:watchexec/watchexec sd:chmln/sd; do
        binary="${release_tool%%:*}"
        repository="${release_tool#*:}"
        command -v "$binary" >/dev/null 2>&1 && continue

        # Both name the artifact after the release, so the tag has to be known
        # before the download URL can be built.
        tag="$(github_latest_tag "$repository")" || tag=""
        if [ -z "$tag" ]; then
          warn "The latest $binary release could not be resolved; $binary stays unavailable."
          continue
        fi

        case "$binary" in
          watchexec) asset="watchexec-${tag#v}-$musl_target.tar.xz" ;;
          sd) asset="sd-$tag-$musl_target.tar.gz" ;;
        esac

        step "Downloading $binary $tag for $musl_target" "*"
        install_release_binary "https://github.com/$repository/releases/download/$tag/$asset" "$binary" ||
          warn "'$binary' could not be installed from its upstream release."
      done

      if ! command -v typst >/dev/null 2>&1; then
        step "Downloading Typst for $musl_target" "*"
        install_release_binary \
          "https://github.com/typst/typst/releases/latest/download/typst-$musl_target.tar.xz" typst ||
          warn "'typst' could not be installed from its upstream release; .typ files preview as source."
      fi
    fi

    if ! command -v duckdb >/dev/null 2>&1; then
      step "Downloading DuckDB for linux-$duckdb_target" "*"
      install_release_binary \
        "https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-$duckdb_target.zip" duckdb ||
        warn "'duckdb' could not be installed from its upstream release; CSV and TSV previews fall back to plain text."
    fi

    if ! command -v choose >/dev/null 2>&1; then
      step "Downloading choose for $(uname -m)" "*"
      install_release_binary \
        "https://github.com/theryangeary/choose/releases/latest/download/$choose_asset" choose ||
        warn "'choose' could not be installed from its upstream release."
    fi

    # bat carries the Catppuccin themes config/.config/bat/config selects only
    # from 0.26.0 onwards. Debian and Ubuntu still package an older release,
    # which prints "Unknown theme 'Catppuccin Mocha', using default" on every
    # run, so replace it with the upstream binary whenever it is too old. That
    # also installs it under its real name rather than the `batcat` APT is
    # forced to use, which is why an existing `batcat` counts as the version
    # to check.
    bat_version=""
    for bat_binary in bat batcat; do
      command -v "$bat_binary" >/dev/null 2>&1 || continue
      bat_version="$("$bat_binary" --version 2>/dev/null | cut -d' ' -f2)"
      [ -n "$bat_version" ] && break
    done

    if [ -z "$bat_version" ] ||
      [ "$(printf '%s\n0.26.0\n' "$bat_version" | sort -V | head -n1)" != "0.26.0" ]; then
      # The artifact is named after the release, so resolve the tag first.
      tag="$(github_latest_tag sharkdp/bat)" || tag=""
      if [ -z "$tag" ]; then
        warn "The latest bat release could not be resolved; bat keeps the packaged version and its default theme."
      else
        step "Downloading bat $tag for $musl_target" "*"
        install_release_binary \
          "https://github.com/sharkdp/bat/releases/download/$tag/bat-$tag-$musl_target.tar.gz" bat ||
          warn "'bat' could not be installed from its upstream release; the Catppuccin Mocha theme stays unavailable."
      fi
    fi
  fi

  # rich-cli is a Python package rather than a released binary, so it comes from
  # a uv tool environment where the python module has installed uv.
  if ! command -v rich >/dev/null 2>&1; then
    if command -v uv >/dev/null 2>&1; then
      step "Installing rich-cli as a uv tool" "*"
      uv tool install rich-cli ||
        warn "uv could not install rich-cli; JSON and reStructuredText preview through Yazi's code previewer."
    else
      warn "rich-cli has no APT candidate and uv is missing; install the python module and rerun this one."
    fi
  fi
fi

if [ "$OS" = "linux" ] && ! command -v ouch >/dev/null 2>&1; then
  if apt_has_candidate ouch; then
    step "Installing Ouch from configured APT sources" "*"
    apt_install ouch
  else
    case "$(uname -m)" in
      x86_64|amd64) target="x86_64-unknown-linux-musl" ;;
      aarch64|arm64) target="aarch64-unknown-linux-musl" ;;
      *) die "Unsupported architecture for Ouch: $(uname -m)" ;;
    esac

    temporary_dir="$(mktemp -d)"
    trap 'rm -rf "$temporary_dir"' EXIT HUP INT TERM
    archive="$temporary_dir/ouch.tar.gz"
    url="https://github.com/ouch-org/ouch/releases/latest/download/ouch-$target.tar.gz"

    step "Downloading Ouch for $target" "*"
    curl -fL --connect-timeout 15 --retry 2 "$url" -o "$archive" || die "Unable to download Ouch."
    tar -xzf "$archive" -C "$temporary_dir" || die "Unable to unpack Ouch."
    source_binary="$(find "$temporary_dir" -type f -name ouch -perm -u+x 2>/dev/null | head -1)"
    [ -n "$source_binary" ] || die "The release does not contain the 'ouch' binary."
    install -Dm755 "$source_binary" "$HOME/.local/bin/ouch"
  fi
fi

if [ "$OS" = "mac" ] && { ! command -v rar >/dev/null 2>&1 || ! command -v unrar >/dev/null 2>&1; }; then
  step "Installing RAR and UnRAR with Homebrew" "*"
  brew install --cask rar
fi

if [ "$OS" = "linux" ]; then
  # RAR support is proprietary: it lives in non-free and is not built for every
  # architecture. Treat it as optional so the rest of the module still counts.
  for package in rar unrar; do
    command -v "$package" >/dev/null 2>&1 && continue
    if apt_has_candidate "$package"; then
      step "Installing $package from configured APT sources" "*"
      apt_install "$package" || warn "'$package' could not be installed."
      continue
    fi

    warn "'$package' is unavailable from the configured APT sources on $(dpkg --print-architecture 2>/dev/null || uname -m)."
    warn "Enable the non-free component, or extract RAR archives with 7z instead."
  done
fi
