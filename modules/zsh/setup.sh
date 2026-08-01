#!/usr/bin/env bash
# Prime Zinit and its plugins right after stow, so the first interactive
# shell does not stall on GitHub clones (zinit light runs synchronously).
# `zsh -ic 'exit'` needs no TTY of its own, so this also warms the cache
# during a `docker build` RUN step.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"

# The numbered files used to live in ~/.config/zsh/import/ and the prompt file
# was ~/.config/zsh/p10k.zsh. Stow only removes links it still owns, so an
# earlier installation leaves those behind pointing at paths that no longer
# exist. Drop the ones that point into this repository and nothing else.
zsh_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
repository_root="$(cd -P "$DOTFILES_DIR" && pwd -P)"

for stale_link in "$zsh_config_dir/import"/*.zsh "$zsh_config_dir/p10k.zsh"; do
  [ -L "$stale_link" ] || continue
  stale_target="$(readlink "$stale_link")"
  case "$stale_target" in
    "$repository_root"/* | *"/.dotfilez/modules/"* | *"/modules/"*/config/*)
      step "Removing the stale link $stale_link" "*"
      rm -f "$stale_link"
      ;;
  esac
done
rmdir "$zsh_config_dir/import" 2>/dev/null || true

step "Priming Zinit and plugins (may download from GitHub)" "*"
# 180s rather than 120s: the run also clones Powerlevel10k and fetches the
# gitstatusd binary the theme uses for Git status.
with_timeout 180 zsh -ic 'exit' \
  || warn "Zinit priming did not finish; plugins will download on the first shell start instead."
