# Store the completion dump in the Zsh cache directory.
zsh_cache_dir="${ZDOTDIR:-$HOME}/.cache/zsh"

# Reuse the history module's cache directory for the completion dump file.
ZSH_COMPDUMP="$zsh_cache_dir/.zcompdump"

# The cache directory helper is no longer needed after the dump path is set.
unset zsh_cache_dir

# Ask before listing only when match count hits this threshold, regardless of
# whether it fits on screen.
LISTMAX=300

# Drop the space a completion appends when the next character typed is one of
# these, so a pipeline comes out as `command| ` rather than `command | `.
ZLE_SPACE_SUFFIX_CHARS=$'&|'

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

  # Cache the results of completers that build their candidate list from a slow
  # source — the package lists behind `brew install` or `apt install`, the
  # targets of a large Makefile. Without it that work repeats on every Tab.
  # This is unrelated to ZSH_COMPDUMP above, which only records which function
  # completes which command. The path keeps the cache files next to the dump
  # rather than in ~/.zcompcache; it is spelled out because the helper variable
  # is gone by the time this function runs.
  zstyle ':completion:*' use-cache yes
  zstyle ':completion:*' cache-path "${ZDOTDIR:-$HOME}/.cache/zsh"

  # Offer `..` as a completion candidate. Plain `true` would add `.` as well,
  # which is never what is wanted at a prompt.
  zstyle ':completion:*' special-dirs ..

  # Treat `foo//bar` as an ordinary path. By default the file completer behaves
  # as if there were a `*` between the slashes and completes through an
  # arbitrary intermediate directory; doubled slashes appear on their own when
  # joining variables that already end in one.
  zstyle ':completion:*' squeeze-slashes true

  # Accept a candidate that exactly matches what was typed instead of treating
  # it as ambiguous: with `log` and `logs` both present, Tab after `log` takes
  # `log`. The value is a glob qualifier, not a boolean — it limits the style to
  # words that resolve to an existing name, and `(N)` keeps a miss quiet.
  zstyle ':completion:*' accept-exact '*(N)'

  # Show completed files as a long listing with permissions, size and date.
  # This loads the zsh/stat module, whose builtin `stat` shadows any external one.
  zstyle ':completion:*' file-list always

  # Put the cursor back on the command line after printing a completion list, so
  # typing can continue without the list pushing the prompt away.
  zstyle ':completion:*' last-prompt yes

  # Position indicator while scrolling a menu too large for the screen.
  zstyle ':completion:*' select-prompt '%Sat %p%s'

  # Describe command options, and synthesise a description from the argument
  # name for options that carry none. Works together with `verbose yes` above.
  zstyle ':completion:*:options' description 'yes'
  zstyle ':completion:*:options' auto-description 'specify: %d'

  # Hide the private helpers of the completion system itself — the hundreds of
  # _git, _docker and _fzf_* names that are never called by hand.
  zstyle ':completion:*:functions' ignored-patterns '_*'
  zstyle ':completion:*:parameters' ignored-patterns '_*'

  # `kill <Tab>` lists this user's processes with PID, owner and command line,
  # the PID highlighted in blue and the owner dimmed. `killall` takes a name
  # rather than a PID, so it gets a command list instead.
  zstyle ':completion:*:*:*:*:processes' command 'ps -u ${USER} -o pid,user,command'
  zstyle ':completion:*:*:*:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-_]#)*=0=01;34=02=0'
  zstyle ':completion:*:*:*:*:processes-names' command 'ps -c -u ${USER} -o command | uniq'
  zstyle ':completion:*:killall:*' command 'ps -u $USER -o command'

  # Group `man <Tab>` candidates by manual section, which matters for a name
  # that exists in several of them: printf, open, stat.
  zstyle ':completion:*:manuals' separate-sections true

  # For cd and pushd, offer subdirectories of the current directory first and
  # named directories after them, rather than mixing both with cdpath entries.
  zstyle ':completion:*:complete:(cd|pushd):*' tag-order 'local-directories named-directories'

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
