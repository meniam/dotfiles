#!/usr/bin/env bash
# Install Yazi and its locked plugins.
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
fi

if command -v ya >/dev/null 2>&1; then
  step "Installing locked Yazi plugins and flavors" "*"
  ya pkg install || warn "Yazi plugins could not be installed automatically."
else
  warn "The 'ya' companion binary is unavailable; plugin installation is skipped."
fi
