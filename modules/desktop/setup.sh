#!/usr/bin/env bash
# Install Hammerspoon, WezTerm, and Kitty using the platform's supported package source.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"
detect_os

if [ "$OS" = "mac" ] && [ ! -d /Applications/Hammerspoon.app ]; then
  step "Installing Hammerspoon with Homebrew" "*"
  brew_cask_install hammerspoon
fi

if ! command -v wezterm >/dev/null 2>&1; then
  case "$OS" in
    mac)
      step "Installing WezTerm with Homebrew" "*"
      brew install --cask wezterm
      ;;
    linux)
      if apt_has_candidate wezterm; then
        step "Installing WezTerm from configured APT sources" "*"
        apt_install wezterm
      else
        warn "WezTerm is unavailable from the configured APT sources."
        warn "Set up the official repository, then rerun this module: https://wezterm.org/install/linux.html"
      fi
      ;;
  esac
fi

if ! command -v kitty >/dev/null 2>&1; then
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
fi
