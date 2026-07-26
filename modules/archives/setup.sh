#!/usr/bin/env bash
# Install Ouch from APT when available, otherwise use its official static release.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"
detect_os

if [ "$OS" = "linux" ] && ! command -v ouch >/dev/null 2>&1; then
  if apt-cache show ouch >/dev/null 2>&1; then
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
  for package in rar unrar; do
    command -v "$package" >/dev/null 2>&1 && continue
    if apt-cache show "$package" >/dev/null 2>&1; then
      step "Installing $package from configured APT sources" "*"
      apt_install "$package"
    else
      warn "'$package' is unavailable from the configured APT sources."
      warn "Enable the appropriate non-free or multiverse repository, then rerun this module."
    fi
  done
fi
