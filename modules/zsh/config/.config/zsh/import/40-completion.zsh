# Store the completion dump in the Zsh cache directory.
zsh_cache_dir="${ZDOTDIR:-$HOME}/.cache/zsh"

# Reuse the history module's cache directory for the completion dump file.
ZSH_COMPDUMP="$zsh_cache_dir/.zcompdump"

# The cache directory helper is no longer needed after the dump path is set.
unset zsh_cache_dir

# Load extra completion definitions before initializing compinit.
zsh_init_completion() {
  # List command options with descriptions and keep the menu open for selection.
  # Case-insensitive matching makes argument discovery forgiving without changing input.
  zstyle ':completion:*' verbose yes
  zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
  zstyle ':completion:*' force-list always
  zstyle ':completion:*:default' menu select
  zstyle ':completion:*:descriptions' format '%F{magenta}%B%d%b%f'
  zstyle ':completion:*' list-separator '--'
  zstyle ':completion:*' group-name ''
  zstyle ':completion:*' list-grouped yes
  zstyle ':completion:*' list-dirs-first yes

  # zsh-completions extends completion support for many third-party commands.
  # Type a command or argument prefix and press Tab to view available completions.
  # Repository: https://github.com/zsh-users/zsh-completions
  zinit ice blockf atpull'zinit creinstall -q .'
  zinit light zsh-users/zsh-completions

  # Build or reuse the completion dump after the extra definitions are available.
  autoload -Uz compinit
  compinit -d "$ZSH_COMPDUMP"

  # Restore the legacy FZF completion shortcut without taking over the Tab key.
  # The package location differs between Homebrew and Debian/Ubuntu installations.
  zsh_load_fzf_completion
}

zsh_load_fzf_completion() {
  local fzf_completion_file fzf_prefix

  if command -v brew >/dev/null 2>&1; then
    fzf_prefix="$(brew --prefix fzf 2>/dev/null)"
    fzf_completion_file="$fzf_prefix/shell/completion.zsh"
    if [[ -r "$fzf_completion_file" ]]; then
      # shellcheck disable=SC1090
      source "$fzf_completion_file"
      return
    fi
  fi

  for fzf_completion_file in \
    /usr/share/doc/fzf/examples/completion.zsh \
    /usr/share/fzf/completion.zsh; do
    if [[ -r "$fzf_completion_file" ]]; then
      # shellcheck disable=SC1090
      source "$fzf_completion_file"
      return
    fi
  done
}
