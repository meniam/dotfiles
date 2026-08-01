# Bootstrap Zinit when needed, then load the shell enhancement plugins.
# Add a plugin with zinit light owner/repository in this file.
# Repository: https://github.com/zdharma-continuum/zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME/.git" ]]; then
  if ! command -v git >/dev/null 2>&1; then
    print -u2 -- 'Zinit requires git. Install git and start Zsh again.'
    return
  fi

  command mkdir -p "${ZINIT_HOME:h}"
  command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" || return
fi

if source "$ZINIT_HOME/zinit.zsh"; then
  zsh_init_completion

  # Prompt theme. Loaded first so the instant prompt replayed by .zshrc is taken
  # over by the real prompt as early as possible. Its settings live in
  # ../p10k.zsh and are applied by 80-prompt.zsh; depth=1 skips the history of a
  # repository that is only ever used at its tip.
  # Repository: https://github.com/romkatv/powerlevel10k
  zinit ice depth=1
  zinit light romkatv/powerlevel10k

  # Suggest commands from history while the command line is being edited.
  # Type a command prefix and press Right Arrow to accept the grey suggestion.
  # Repository: https://github.com/zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-autosuggestions

  # Load syntax highlighting before history search so both highlight the command line correctly.
  # Type a command normally; valid commands, options, and paths are colored automatically.
  # Repository: https://github.com/zdharma-continuum/fast-syntax-highlighting
  zinit light zdharma-continuum/fast-syntax-highlighting

  # Search history entries containing the typed text with the Up and Down arrows.
  # Type part of a previous command, then press Up or Down to cycle through matches.
  # Repository: https://github.com/zsh-users/zsh-history-substring-search
  zinit light zsh-users/zsh-history-substring-search

  # Match the command-line selection color to the terminal's text selection color.
  # See selection_bg/selection_fg in wezterm.lua for the terminal-side counterpart.
  zle_highlight=('region:bg=#ffdd2d,fg=#000000')

  # Select command-line text with Shift-modified navigation keys.
  # Cmd+C copies the active region to the macOS clipboard through the widget below.
  # Repository: https://github.com/jirutka/zsh-shift-select
  zinit light jirutka/zsh-shift-select

  # Copy the active command-line region to both the ZLE kill buffer and pbcopy.
  # WezTerm sends this private sequence when Cmd+C has no terminal selection.
  copy-zle-region-to-clipboard() {
    (( REGION_ACTIVE && MARK != CURSOR )) || return 0

    if (( ! $+commands[pbcopy] )); then
      zle -M 'pbcopy is not available.'
      return 1
    fi

    zle copy-region-as-kill
    if ! print -rn -- "$CUTBUFFER" | command pbcopy; then
      zle -M 'Failed to copy the selected text with pbcopy.'
      return 1
    fi
  }
  zle -N copy-zle-region-to-clipboard
  bindkey -M emacs '^[[99~' copy-zle-region-to-clipboard
  bindkey -M shift-select '^[[99~' copy-zle-region-to-clipboard

  # Keep the legacy fuzzy search and match-highlighting appearance.
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=default,fg=magenta,bold'
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=default,fg=black,bold'
  HISTORY_SUBSTRING_SEARCH_FUZZY=true

  # Bind common terminal escape sequences and terminfo keys to history search.
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  [[ -n "${terminfo[kcuu1]:-}" ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
  [[ -n "${terminfo[kcud1]:-}" ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
fi

# Load fzf's interactive widgets after the plugins so that a later plugin cannot
# take the keys back. Ctrl+R fuzzy-searches the shell history, Ctrl+T inserts
# paths from below the current directory into the command line, and Alt+C
# changes to one of those directories. 40-completion.zsh resolved where the
# script lives; the widgets read the FZF_* variables set in 30-env.zsh.
#
# Ctrl+T replaces the Emacs transpose-chars binding, and Alt+C only arrives when
# the terminal sends Option as a real Alt modifier, which Kitty does not do on
# macOS until macos_option_as_alt is set.
if [[ -n "$zsh_fzf_shell_dir" && -r "$zsh_fzf_shell_dir/key-bindings.zsh" ]]; then
  # shellcheck disable=SC1090
  source "$zsh_fzf_shell_dir/key-bindings.zsh"
fi

unset zsh_fzf_shell_dir
