#!/usr/bin/env bash
# Install WezTerm without modifying third-party APT repository settings.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"
detect_os

command -v wezterm >/dev/null 2>&1 && exit 0

case "$OS" in
  mac)
    step "Installing WezTerm with Homebrew" "*"
    brew install --cask wezterm
    ;;
  linux)
    if apt-cache show wezterm >/dev/null 2>&1; then
      step "Installing WezTerm from configured APT sources" "*"
      apt_install wezterm
    else
      warn "WezTerm is unavailable from the configured APT sources."
      warn "Set up the official repository, then rerun this module: https://wezterm.org/install/linux.html"
    fi
    ;;
esac
