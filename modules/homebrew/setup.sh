#!/usr/bin/env bash
# Bootstrap Homebrew when it is missing, refresh its package metadata, and
# prepare the directory the Brewfile snapshot helper writes to.
set -euo pipefail

. "$DOTFILES_DIR/lib/common.sh"
detect_os

[ "$OS" = "mac" ] || die "The homebrew module supports macOS only."

ensure_homebrew

[ -n "${HOME:-}" ] || die "HOME is not set; refusing to create the snapshot directory."
snapshot_dir="${XDG_CONFIG_HOME:-$HOME/.config}/homebrew"
mkdir -p "$snapshot_dir"

# brew bundle is a built-in command in Homebrew 4.4 and later. On an older
# installation the snapshot helper would fail at run time instead of here.
brew bundle --help >/dev/null 2>&1 ||
  warn "This Homebrew build has no 'brew bundle'; brew-snapshot will not work until it is updated."

# The metadata refresh is a convenience and reaches the network, so a failure
# leaves the cached formulae in place instead of failing the module.
step "Refreshing Homebrew package metadata" "*"
with_timeout 300 brew update ||
  warn "brew update failed; continuing with the cached package metadata."

step "Homebrew: $(brew --version | head -1)" "*"
