#!/usr/bin/env bash
# Create the ControlMaster socket directory and tighten ~/.ssh permissions.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"

[ -n "${HOME:-}" ] || die "HOME is not set; refusing to touch ~/.ssh."

step "Preparing ~/.ssh" "*"

# ssh never creates the directory its ControlPath points at, and a missing one
# makes multiplexing fail without an error on the default log level.
mkdir -p "$HOME/.ssh/sockets"

# The config Includes ~/.ssh/config.d/*.conf. ssh ignores a glob that matches
# nothing, so the directory is only created to have the drop-in location ready
# with the right mode from the start.
mkdir -p "$HOME/.ssh/config.d"

# stow creates ~/.ssh with the process umask, which usually leaves it readable
# by the group and by others. ssh refuses to use private keys from a directory
# other users can reach.
chmod 700 "$HOME/.ssh" "$HOME/.ssh/sockets" "$HOME/.ssh/config.d"
