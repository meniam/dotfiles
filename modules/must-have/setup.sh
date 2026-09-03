#!/usr/bin/env bash
# Install micro editor plugins.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"

if command -v micro >/dev/null 2>&1; then
  step "Installing micro plugins" "*"
  for plugin in fzf filemanager editorconfig palettero manipulator detectindent quoter joinLines toggle mdtblfmt; do
    micro -plugin install "$plugin" || warn "micro plugin '$plugin' could not be installed automatically."
  done

  # Plugins an earlier run of this module installed and that no longer earn their
  # place. The colorschemes ship with micro's own runtime since 2.0.14, so their
  # plugins now only shadow the built-in files; snippets is an archived repository.
  #
  # The directory goes rather than `micro -plugin remove`, which resolves the name
  # against the plugin channel first and quietly succeeds without removing
  # anything once the plugin has been dropped from it — as all three have been.
  # `repo.json` has to be there for the path to be a plugin micro installed, so a
  # directory that is anything else is left alone.
  micro_plug_dir="${MICRO_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/micro}/plug"
  for plugin in gotham-colors monokai-dark snippets; do
    if [ -f "$micro_plug_dir/$plugin/repo.json" ]; then
      rm -rf "${micro_plug_dir:?}/$plugin" || warn "micro plugin '$plugin' could not be removed automatically."
      log "Removed the retired micro plugin '$plugin'."
    fi
  done

  # filemanager 3.5.1 resolves a click in its tree with
  # `BufPane:GetMouseClickLocation`, a method micro dropped in 2.0, so every
  # click reports "attempt to call a non-function object" and opens nothing.
  # `LocFromVisual` replaces it. Upstream still ships the old call, so the file
  # is patched after each install; the grep makes the step idempotent and skips
  # a release that fixed it.
  filemanager_lua="$micro_plug_dir/filemanager/filemanager.lua"
  if [ -f "$filemanager_lua" ] && grep -q "GetMouseClickLocation" "$filemanager_lua"; then
    # A temporary file instead of `sed -i`, whose in-place flag takes an
    # argument on BSD sed and none on GNU sed.
    if sed \
      -e 's/local new_x, new_y = tree_view:GetMouseClickLocation(x, y)/local click_loc = tree_view:LocFromVisual(buffer.Loc(x, y))/' \
      -e 's/try_open_at_y(new_y)/try_open_at_y(click_loc.Y)/' \
      "$filemanager_lua" >"$filemanager_lua.patched"; then
      mv "$filemanager_lua.patched" "$filemanager_lua"
      log "Patched the micro filemanager plugin for mouse clicks."
    else
      rm -f "$filemanager_lua.patched"
      warn "micro plugin 'filemanager' could not be patched for mouse clicks."
    fi
  fi
else
  warn "micro is unavailable; plugin installation is skipped."
fi
