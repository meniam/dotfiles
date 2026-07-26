#!/usr/bin/env bash
# Install Kitty using the platform's supported package source.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"
detect_os

command -v kitty >/dev/null 2>&1 && exit 0

case "$OS" in
  mac)
    step "Installing Kitty with Homebrew" "*"
    brew install --cask kitty
    ;;
  linux)
    step "Installing Kitty from configured APT sources" "*"
    apt_install kitty
    ;;
esac
