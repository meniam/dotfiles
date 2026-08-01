# Store Zsh history in the cache directory defined for this module.
zsh_cache_dir="${ZDOTDIR:-$HOME}/.cache/zsh"

# Load Zsh's file builtins so cache setup works even with an incomplete PATH.
zmodload zsh/files
mkdir -p "$zsh_cache_dir"

# Keep the legacy history capacity in memory and on disk.
HISTFILE="$zsh_cache_dir/.zhistory"
HISTSIZE=100000
SAVEHIST=$HISTSIZE

# Append commands, share history across sessions, and skip consecutive duplicates.
setopt append_history hist_ignore_dups share_history

# Keep a command starting with a space out of the history. The usual way to run
# something with a secret on the command line without recording it.
setopt hist_ignore_space

# Expand !!, !$ and ^old^new into the command line and wait for Enter instead of
# running the result straight away, so `sudo !!` can be read before it executes.
setopt hist_verify

# Record how long each command ran. share_history already writes the timestamp,
# but leaves the duration field at 0; this fills it in, and `history -D` shows it.
setopt extended_history

# Skip a result already shown while walking back through the history.
setopt hist_find_no_dups

# Do not beep when Up runs past the oldest entry. On by default in zsh.
unsetopt hist_beep

# INC_APPEND_HISTORY is deliberately absent: share_history already appends every
# command as it is typed, and `man zshoptions` says the option "should be turned
# off if this option is in effect".

# Edit the history file in $EDITOR and re-read it afterwards — how a secret that
# made it into the history gets removed. Takes an optional editor argument.
edit-history() {
  ${1:-${EDITOR:-vi}} "$HISTFILE" && fc -R
}

# The cache directory helper is no longer needed after history setup.
unset zsh_cache_dir
