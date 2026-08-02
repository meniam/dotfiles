#!/usr/bin/env bash
# lazygit ignores XDG_CONFIG_HOME on macOS (Go's os.UserConfigDir hardcodes
# ~/Library/Application Support there), so the config.yml stowed at
# ~/.config/lazygit is invisible to it unless mirrored to its real config dir.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"
detect_os

[ "$OS" = "mac" ] || exit 0
command -v lazygit >/dev/null 2>&1 || exit 0

source_config="$HOME/.config/lazygit/config.yml"
[ -e "$source_config" ] || exit 0

lazygit_config_dir="$(lazygit --print-config-dir)"
target_config="$lazygit_config_dir/config.yml"

if [ -L "$target_config" ]; then
  [ "$(readlink "$target_config")" = "$source_config" ] && exit 0
  rm "$target_config"
elif [ -e "$target_config" ]; then
  if [ -s "$target_config" ]; then
    warn "Leaving non-empty $target_config alone; it won't be managed by dotfiles."
    exit 0
  fi
  rm "$target_config"
fi

mkdir -p "$lazygit_config_dir"
ln -s "$source_config" "$target_config"
success "Linked lazygit config: $target_config -> $source_config"
