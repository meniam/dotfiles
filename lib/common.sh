#!/usr/bin/env bash
# Shared helpers for the modular dotfiles installer.

c_blue=$'\033[1;34m'
c_green=$'\033[1;32m'
c_yellow=$'\033[1;33m'
c_red=$'\033[1;31m'
c_dim=$'\033[2m'
c_bold=$'\033[1m'
c_reset=$'\033[0m'

VERBOSE="${VERBOSE:-0}"

log() {
  [ "$VERBOSE" = "1" ] || return 0
  printf "${c_blue}>${c_reset} %s\n" "$*" >&2
}
success() { printf "${c_green}ok${c_reset} %s\n" "$*" >&2; }
warn() { printf "${c_yellow}!${c_reset} %s\n" "$*" >&2; }
die() { printf "${c_red}error:${c_reset} %s\n" "$*" >&2; exit 1; }

header() {
  printf '\n%s%s[%s/%s] %s%s  %s%s%s\n' \
    "$c_bold" "$c_blue" "$1" "$2" "$3" "$c_reset" "$c_dim" "${4:-}" "$c_reset" >&2
}

step() {
  [ "$VERBOSE" = "1" ] || return 0
  printf '   %s %s\n' "${2:-·}" "$1" >&2
}

detect_os() {
  case "$(uname -s)" in
    Darwin) OS="mac" ;;
    Linux) OS="linux" ;;
    *) die "Unsupported operating system: $(uname -s)" ;;
  esac
}

SUDO=""
[ "$(id -u)" -eq 0 ] 2>/dev/null || SUDO="sudo"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH

with_timeout() {
  local seconds="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$seconds" "$@"
  else
    "$@"
  fi
}

glibc_version() {
  local version
  version="$(getconf GNU_LIBC_VERSION 2>/dev/null)" || version=""
  case "$version" in
    glibc\ *) printf '%s' "${version#glibc }" ;;
    *) ldd --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | tail -1 ;;
  esac
}

glibc_at_least() {
  local wanted_major="$1" wanted_minor="$2" version major minor
  version="$(glibc_version)"
  [ -n "$version" ] || return 0
  major="${version%%.*}"
  minor="${version#*.}"
  minor="${minor%%.*}"
  [ "$major" -gt "$wanted_major" ] && return 0
  [ "$major" -lt "$wanted_major" ] && return 1
  [ "$minor" -ge "$wanted_minor" ]
}

apt_install() {
  [ "$#" -gt 0 ] || return 0
  export DEBIAN_FRONTEND=noninteractive
  # shellcheck disable=SC2086
  $SUDO apt-get install -y --no-install-recommends "$@"
}

# True when APT can actually install a package. `apt-cache show` is not enough:
# it also succeeds for a package APT merely knows about, such as one built for
# another architecture or living in a component that is not enabled.
apt_has_candidate() {
  local candidate
  candidate="$(apt-cache policy "$1" 2>/dev/null | awk '/^  Candidate:/ { print $2; exit }')"
  [ -n "$candidate" ] && [ "$candidate" != "(none)" ]
}

# Reduce a package list to the tokens APT can actually install. Manifests target
# several Debian and Ubuntu releases, so a package that only exists on a newer
# release must be skipped instead of aborting the whole module.
apt_filter_available() {
  local package available=""
  for package in "$@"; do
    if apt_has_candidate "$package"; then
      available="$available $package"
    else
      warn "APT has no candidate for '$package'; skipping it."
    fi
  done
  printf '%s' "${available# }"
}

# Default Homebrew prefix for the current macOS architecture. Apple silicon and
# Intel install to different roots, and neither is on PATH before the shellenv
# of a fresh installation is evaluated.
homebrew_prefix() {
  case "$(uname -m)" in
    arm64) printf '/opt/homebrew' ;;
    *) printf '/usr/local' ;;
  esac
}

# Put an existing or freshly installed Homebrew on PATH. Every macOS module
# installs its packages through brew, so this runs before the first module.
ensure_homebrew() {
  command -v brew >/dev/null 2>&1 && return 0

  local prefix installer_dir
  prefix="${HOMEBREW_PREFIX:-$(homebrew_prefix)}"

  if [ ! -x "$prefix/bin/brew" ]; then
    # Not step(): this takes minutes and the upstream installer asks for a
    # password, so it must be visible without --verbose.
    warn "Homebrew is missing; installing it into $prefix. The upstream installer can ask for your password."
    installer_dir="$(mktemp -d)"

    # The upstream script is the only supported way to bootstrap Homebrew. It is
    # downloaded to a file and inspected instead of being piped into a shell, so
    # a truncated transfer or an error page cannot be executed as a half script.
    if ! curl -fsSL --connect-timeout 15 --retry 2 \
      "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" \
      -o "$installer_dir/install.sh"; then
      rm -rf "$installer_dir"
      die "Unable to download the Homebrew installer."
    fi

    if ! head -1 "$installer_dir/install.sh" | grep -q '^#!/bin/bash' ||
      ! grep -q 'HOMEBREW_PREFIX' "$installer_dir/install.sh"; then
      rm -rf "$installer_dir"
      die "The downloaded Homebrew installer does not look like the upstream script."
    fi

    # NONINTERACTIVE skips the confirmation prompt. The installer calls sudo on
    # its own where it needs it, so it must not be run through $SUDO.
    if ! NONINTERACTIVE=1 /bin/bash "$installer_dir/install.sh"; then
      rm -rf "$installer_dir"
      die "The Homebrew installer failed. Install it manually from https://brew.sh."
    fi
    rm -rf "$installer_dir"
  fi

  [ -x "$prefix/bin/brew" ] || die "Homebrew is not at $prefix/bin/brew after the installation."
  eval "$("$prefix/bin/brew" shellenv)"
  command -v brew >/dev/null 2>&1 || die "Homebrew is installed but is not on PATH."
}

brew_install() {
  [ "$#" -gt 0 ] || return 0
  local formula
  local -a missing_formulas
  missing_formulas=()

  for formula in "$@"; do
    brew list --formula "$formula" >/dev/null 2>&1 || missing_formulas+=("$formula")
  done

  [ "${#missing_formulas[@]}" -gt 0 ] || return 0
  brew install "${missing_formulas[@]}"
}

brew_cask_install() {
  [ "$#" -gt 0 ] || return 0
  local cask
  local -a missing_casks
  missing_casks=()

  for cask in "$@"; do
    brew list --cask "$cask" >/dev/null 2>&1 || missing_casks+=("$cask")
  done

  [ "${#missing_casks[@]}" -gt 0 ] || return 0
  brew install --cask "${missing_casks[@]}"
}

ensure_base_tools() {
  case "$OS" in
    linux)
      command -v apt-get >/dev/null 2>&1 || die "This Linux installer requires apt-get."
      step "Installing base tools (git, curl, ca-certificates)" "*"
      # shellcheck disable=SC2086
      $SUDO apt-get update -y
      apt_install git curl ca-certificates
      ;;
    mac)
      ensure_homebrew
      ;;
  esac
}

install_packages_for() {
  local module_dir="$1" package_file packages cask_file casks
  case "$OS" in
    linux) package_file="$module_dir/packages.apt" ;;
    mac) package_file="$module_dir/packages.brew" ;;
  esac

  if [ -f "$package_file" ]; then
    packages="$(awk '!/^[[:space:]]*(#|$)/ { print }' "$package_file" | tr '\n' ' ')"
    if [ -n "$packages" ]; then
      log "Packages ($OS): $packages"
      # Package manifests contain one simple package name per line.
      case "$OS" in
        linux)
          # shellcheck disable=SC2086
          packages="$(apt_filter_available $packages)"
          if [ -n "$packages" ]; then
            # shellcheck disable=SC2086
            apt_install $packages
          else
            warn "No installable APT package remains for this module."
          fi
          ;;
        mac)
          # shellcheck disable=SC2086
          brew_install $packages
          ;;
      esac
    fi
  fi

  [ "$OS" = "mac" ] || return 0
  cask_file="$module_dir/casks.brew"
  [ -f "$cask_file" ] || return 0
  casks="$(awk '!/^[[:space:]]*(#|$)/ { print }' "$cask_file" | tr '\n' ' ')"
  [ -n "$casks" ] || return 0
  log "Casks (mac): $casks"
  # Cask manifests contain one simple cask token per line.
  # shellcheck disable=SC2086
  brew_cask_install $casks
}

ensure_stow() {
  command -v stow >/dev/null 2>&1 && return 0
  log "Installing GNU Stow."
  case "$OS" in
    linux) apt_install stow ;;
    mac) brew_install stow ;;
  esac
  command -v stow >/dev/null 2>&1 || die "GNU Stow could not be installed."
}

# Physical path a symlink points at, with its parent directory resolved.
link_destination() {
  local link="$1" destination destination_dir
  destination="$(readlink "$link")" || return 1
  case "$destination" in
    /*) ;;
    *) destination="$(dirname "$link")/$destination" ;;
  esac
  destination_dir="$(cd -P "$(dirname "$destination")" 2>/dev/null && pwd -P)" || return 1
  printf '%s/%s' "$destination_dir" "$(basename "$destination")"
}

# True when any parent directory of a $HOME-relative path is a symlink.
has_symlinked_parent() {
  local relative prefix="$HOME" component saved_ifs
  relative="$(dirname "$1")"
  [ "$relative" = "." ] && return 1
  saved_ifs="$IFS"
  IFS=/
  # shellcheck disable=SC2086
  set -- $relative
  IFS="$saved_ifs"
  for component in "$@"; do
    prefix="$prefix/$component"
    [ -L "$prefix" ] && return 0
  done
  return 1
}

stow_module() {
  local module_dir="$1"
  local package="$module_dir/config"
  [ -d "$package" ] || return 0
  [ -n "${HOME:-}" ] || die "HOME is not set; refusing to touch dotfiles."

  local backup_root relative target backup target_dir repo_root destination
  backup_root="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)-$$"
  repo_root="$(cd -P "${DOTFILES_DIR:-$module_dir/../..}" && pwd -P)"
  while IFS= read -r relative; do
    relative="${relative#./}"
    target="$HOME/$relative"

    # Stow folds directories, so an earlier run can leave ~/.config/nvim as a
    # symlink into this repository, and a user can point it anywhere else.
    # Either way the path resolves outside ~, and moving the target would
    # delete the real file instead of backing up a copy of it.
    if has_symlinked_parent "$relative"; then
      log "Skipping ~/$relative: a parent directory is a symlink."
      continue
    fi

    if [ -L "$target" ]; then
      # A link this repository already owns is left for stow to restow.
      # A foreign one is moved aside, otherwise stow aborts on the conflict.
      destination="$(link_destination "$target")" || destination=""
      case "$destination/" in
        "$repo_root"/*) continue ;;
      esac
    elif [ ! -e "$target" ]; then
      continue
    else
      target_dir="$(cd -P "$(dirname "$target")" 2>/dev/null && pwd -P)" || continue
      case "$target_dir/" in
        "$repo_root"/*) continue ;;
      esac
    fi

    backup="$backup_root/$relative"
    mkdir -p "$(dirname "$backup")"
    mv "$target" "$backup"
    warn "Backed up ~/$relative to $backup"
  done < <(cd "$package" && find . \( -type f -o -type l \) -print)

  # --no-folding: several modules share top-level directories such as
  # ~/.config. Folding would replace ~/.config with a symlink into whichever
  # module's package stows it first, and every later module would then see
  # a ~/.config "not owned" by its own stow directory and abort.
  stow -d "$module_dir" -t "$HOME" --no-folding --restow config
}

unstow_module() {
  local module_dir="$1"
  [ -d "$module_dir/config" ] || return 0
  stow -d "$module_dir" -t "$HOME" --no-folding -D config
}
