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

# The cache directory helper is no longer needed after history setup.
unset zsh_cache_dir
