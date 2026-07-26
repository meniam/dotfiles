#!/usr/bin/env bash
# Install Hammerspoon only when its application bundle is unavailable.
set -euo pipefail

. "$DOTFILES_DIR/lib/common.sh"

[ "$OS" = "mac" ] || exit 0
[ -d /Applications/Hammerspoon.app ] && exit 0

step "Installing Hammerspoon with Homebrew" "*"
brew_cask_install hammerspoon
