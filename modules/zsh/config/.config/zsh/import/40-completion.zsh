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
  # shellcheck disable=SC2086,SC2296
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

  # zsh-completions extends completion support for many third-party commands.
  # Type a command or argument prefix and press Tab to view available completions.
  # Repository: https://github.com/zsh-users/zsh-completions
  zinit ice blockf atpull'zinit creinstall -q .'
  zinit light zsh-users/zsh-completions

  # Build or reuse the completion dump after the extra definitions are available.
  autoload -Uz compinit
  compinit -d "$ZSH_COMPDUMP"

  # Step backwards through the completion menu with Shift+Tab. Tab already walks
  # forwards, but Zsh ships no reverse binding: neither the emacs keymap nor the
  # menuselect keymap claims the Shift+Tab sequence, so overshooting a candidate
  # meant cycling through the whole list again. terminfo's kcbt holds the escape
  # sequence for the current terminal and the literal is the fallback for
  # descriptions that omit it. The menuselect keymap comes from zsh/complist,
  # which `menu select` above loads on first use, so request it explicitly before
  # binding into it.
  zmodload zsh/complist
  zmodload zsh/terminfo
  bindkey '^[[Z' reverse-menu-complete
  bindkey -M menuselect '^[[Z' reverse-menu-complete
  if [[ -n "${terminfo[kcbt]:-}" ]]; then
    bindkey "${terminfo[kcbt]}" reverse-menu-complete
    bindkey -M menuselect "${terminfo[kcbt]}" reverse-menu-complete
  fi

  # Ask just for completions at runtime so Tab lists recipes from the current justfile.
  # The generated script delegates recipe and argument discovery to just itself.
  if command -v just >/dev/null 2>&1; then
    # shellcheck disable=SC1090
    source <(just --completions zsh)
  fi

  # Restore the legacy FZF completion shortcut without taking over the Tab key.
  if [[ -r "$zsh_fzf_shell_dir/completion.zsh" ]]; then
    # shellcheck disable=SC1090
    source "$zsh_fzf_shell_dir/completion.zsh"
  fi
}

# Directory holding fzf's Zsh integration scripts, completion.zsh and
# key-bindings.zsh. fzf installs them outside every directory Zsh searches and
# Homebrew and Debian/Ubuntu use different prefixes, so the candidates are tried
# in order. The lookup runs here rather than in each consumer because
# `brew --prefix` forks a process: the completion trigger above and the key
# bindings loaded by 50-plugins.zsh both read the resolved value.
zsh_fzf_shell_dir=''

zsh_resolve_fzf_shell_dir() {
  local candidate

  if command -v brew >/dev/null 2>&1; then
    candidate="$(brew --prefix fzf 2>/dev/null)/shell"
    if [[ -d "$candidate" ]]; then
      zsh_fzf_shell_dir="$candidate"
      return
    fi
  fi

  for candidate in /usr/share/doc/fzf/examples /usr/share/fzf; do
    if [[ -d "$candidate" ]]; then
      zsh_fzf_shell_dir="$candidate"
      return
    fi
  done
}

zsh_resolve_fzf_shell_dir
