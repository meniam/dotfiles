#!/usr/bin/env bash
# Pull the module's .gitconfig into Git's global config.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"

# ~/.config/git/.gitconfig is not one of Git's auto-discovered config paths
# (those are ~/.gitconfig and ~/.config/git/config), so it has to be pulled in
# explicitly. It in turn [include]s core.conf, color.conf, diff.conf, urls.conf,
# lfs.conf, aliases.conf, delta.conf, work.conf, and personal.conf.
#include_path="$HOME/.config/git/.gitconfig"
#git config --global --get-all include.path 2>/dev/null | grep -qxF "$include_path" \
#  || git config --global --add include.path "$include_path"