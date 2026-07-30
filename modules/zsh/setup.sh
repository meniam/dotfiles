#!/usr/bin/env bash
# Prime Zinit and its plugins right after stow, so the first interactive
# shell does not stall on GitHub clones (zinit light runs synchronously).
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"

if have_tty; then
  step "Priming Zinit and plugins (may download from GitHub)" "*"
  with_timeout 120 zsh -ic 'exit' \
    || warn "Zinit priming did not finish; plugins will download on the first shell start instead."
else
  warn "No TTY detected; skipping Zinit priming. Plugins will download on the first interactive shell."
fi
