#!/usr/bin/env bash
# Install micro editor plugins.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"

if command -v micro >/dev/null 2>&1; then
  step "Installing micro plugins" "*"
  for plugin in fzf filemanager editorconfig palettero monokai-dark gotham-colors; do
    micro -plugin install "$plugin" || warn "micro plugin '$plugin' could not be installed automatically."
  done
else
  warn "micro is unavailable; plugin installation is skipped."
fi
