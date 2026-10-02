#!/usr/bin/env bash
# Create the ControlMaster socket directory, seed ~/.ssh/config, and tighten
# ~/.ssh permissions.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"

[ -n "${HOME:-}" ] || die "HOME is not set; refusing to touch ~/.ssh."

step "Preparing ~/.ssh" "*"

# ssh never creates the directory its ControlPath points at, and a missing one
# makes multiplexing fail without an error on the default log level.
mkdir -p "$HOME/.ssh/sockets"

# stow links the defaults into config.d, so the directory already exists by
# now; this only covers a run of setup.sh on its own.
mkdir -p "$HOME/.ssh/config.d"

# ~/.ssh/config belongs to the machine, not to the repository. Tools such as
# OrbStack, Colima, or VS Code Remote append to it or rewrite it in place, and
# through a symlink those edits landed in the tracked file. An older version
# of this module stowed it as such a link; drop it so a real file replaces it.
config="$HOME/.ssh/config"
if [ -L "$config" ]; then
  case "$(readlink "$config")" in
    *modules/ssh/config/.ssh/config) rm "$config" ;;
  esac
fi

# The Include is the whole contract: hosts go in config.d drop-ins, and ssh
# skips a glob that matches nothing. An existing file is kept, and only gains
# the Include at the very top when it has none for config.d yet. It has to
# come first: an Include placed after a Host line only applies to that host.
if ! grep -iqE '^[[:space:]]*Include[[:space:]].*config\.d/' "$config" 2>/dev/null; then
  tmp="$(mktemp "$HOME/.ssh/config.XXXXXX")"
  {
    if [ -e "$config" ]; then
      printf '%s\n' \
        "# Added by the dotfiles ssh module: defaults in config.d/zz-defaults.conf." \
        'Include ~/.ssh/config.d/*.conf' \
        ''
      cat "$config"
    else
      cat <<'EOF'
# Machine-local OpenSSH client config. Not tracked by the dotfiles repository,
# so tools are free to edit it.
#
# ssh keeps the FIRST value it obtains for every keyword, and an Include placed
# after a Host line only applies to that host. Put hosts in a config.d drop-in
# rather than here, so they are read before the catch-all defaults in
# config.d/zz-defaults.conf.
Include ~/.ssh/config.d/*.conf
EOF
    fi
  } >"$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$config"
fi

# stow creates ~/.ssh with the process umask, which usually leaves it readable
# by the group and by others. ssh refuses to use private keys from a directory
# other users can reach.
chmod 700 "$HOME/.ssh" "$HOME/.ssh/sockets" "$HOME/.ssh/config.d"
