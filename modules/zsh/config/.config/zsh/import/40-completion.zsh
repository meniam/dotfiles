# Store the completion dump in the Zsh cache directory.
zsh_cache_dir="${ZDOTDIR:-$HOME}/.cache/zsh"

# Reuse the history module's cache directory for the completion dump file.
ZSH_COMPDUMP="$zsh_cache_dir/.zcompdump"

# The cache directory helper is no longer needed after the dump path is set.
unset zsh_cache_dir

# Load extra completion definitions before initializing compinit.
zsh_init_completion() {
  # Keep completion candidates grouped and let fzf-tab render the selection menu.
  # Group labels make command options and other mixed completion results easier to scan.
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':completion:*' menu no

  # Preview directory contents while completing an argument for cd.
  # The selected path is supplied by fzf-tab as the realpath variable.
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

  # Use a compact FZF menu and switch completion groups with the < and > keys.
  # These flags apply only to fzf-tab and do not affect other FZF integrations.
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border
  zstyle ':fzf-tab:*' switch-group '<' '>'

  # zsh-completions extends completion support for many third-party commands.
  # Type a command or argument prefix and press Tab to view available completions.
  # Repository: https://github.com/zsh-users/zsh-completions
  zinit ice blockf atpull'zinit creinstall -q .'
  zinit light zsh-users/zsh-completions

  # Build or reuse the completion dump after the extra definitions are available.
  autoload -Uz compinit
  compinit -d "$ZSH_COMPDUMP"
}
