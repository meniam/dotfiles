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
# The shell is primed on a terminal of its own. zsh only enables zle when its
# stdin is a terminal, and Powerlevel10k starts gitstatusd through zle, so
# priming on a plain pipe ends in "can't change option: zle" and a red
# "gitstatus failed to initialize" block that reads like a broken install.
# Handing zsh the terminal of the installer instead is what used to hang the
# run: `timeout` puts its child in a new process group, and an interactive zsh
# calls tcsetpgrp() on the terminal, takes SIGTTOU as a background group, and
# stops — a stopped process never acts on the SIGTERM that follows. script(1)
# gives the shell a pseudo-terminal that belongs to it alone, so zle works and
# no other process group owns the terminal it grabs.
if command -v script >/dev/null 2>&1; then
  case "$OS" in
    # BSD script takes the typescript file first and the command after it;
    # util-linux takes the command through -c. Both return the child's status
    # with -e, which is what the timeout and the warning below rely on.
    mac) set -- script -qe /dev/null zsh -ic exit ;;
    *) set -- script -qec "zsh -ic exit" /dev/null ;;
  esac
else
  set -- zsh -ic exit
fi

# A terminal type has to come with the terminal. An installer started over SSH
# without a TTY inherits no TERM and Bash hands this script `dumb` instead, on
# which the Zinit run dies right after the Powerlevel10k clone: three of the
# seven plugins arrive and the rest are left for the first interactive shell,
# which is the stall the priming exists to avoid. The value only has to name a
# terminal terminfo knows; the pseudo-terminal itself accepts anything.
case "${TERM:-}" in
  "" | dumb | unknown) TERM="xterm-256color" ;;
esac
export TERM

# 180s rather than 120s: the run also clones Powerlevel10k, whose repository is
# the largest of the set.
prime_log="$(mktemp)"
trap 'rm -f "$prime_log"' EXIT HUP INT TERM
# The pseudo-terminal echoes the shell's own startup back into the log, so it
# is only worth showing when the priming actually failed.
if ! with_timeout 180 "$@" </dev/null >"$prime_log" 2>&1; then
  warn "Zinit priming did not finish; plugins will download on the first shell start instead."
  cat "$prime_log" >&2
fi
rm -f "$prime_log"
trap - EXIT HUP INT TERM
