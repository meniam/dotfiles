#!/usr/bin/env bash
# Install Ouch from APT when available, otherwise use its official static release.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"
detect_os

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

    if [ "$package" = "unrar" ] && apt_has_candidate unrar-free; then
      step "Installing unrar-free instead of the non-free unrar" "*"
      apt_install unrar-free || warn "'unrar-free' could not be installed."
      continue
    fi

    warn "'$package' is unavailable from the configured APT sources on $(dpkg --print-architecture 2>/dev/null || uname -m)."
    warn "Enable the non-free component, or extract RAR archives with 7z instead."
  done
fi
