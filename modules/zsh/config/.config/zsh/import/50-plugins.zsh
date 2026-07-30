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
