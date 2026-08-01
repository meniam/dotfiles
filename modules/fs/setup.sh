#!/usr/bin/env bash
# Install Yazi and its locked plugins, plus Ouch and RAR/UnRAR for archives.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"
detect_os

if [ "$OS" = "linux" ] && ! { command -v yazi >/dev/null 2>&1 && yazi --version >/dev/null 2>&1; }; then
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
  if ! ya pkg install >"$pkg_log" 2>&1; then
    warn "Yazi plugins could not be installed automatically."
    cat "$pkg_log" >&2
  fi
  rm -f "$pkg_log"
  trap - EXIT HUP INT TERM
else
  warn "The 'ya' companion binary is unavailable; plugin installation is skipped."
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
