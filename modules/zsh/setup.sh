#!/usr/bin/env bash
# Prime Zinit and its plugins right after stow, so the first interactive
# shell does not stall on GitHub clones (zinit light runs synchronously).
# `zsh -ic 'exit'` needs no TTY of its own, so this also warms the cache
# during a `docker build` RUN step.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"

step "Priming Zinit and plugins (may download from GitHub)" "*"
with_timeout 120 zsh -ic 'exit' \
  || warn "Zinit priming did not finish; plugins will download on the first shell start instead."
