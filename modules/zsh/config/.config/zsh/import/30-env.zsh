# Hide Homebrew environment-variable hints without disabling automatic updates.
export HOMEBREW_NO_ENV_HINTS=1

# Initialize Zoxide's directory-jumping command and record directory changes.
# Type 'z <query>' to jump to a frequently used directory matching the query.
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# Keep Yazi's Zoxide picker fuzzy instead of requiring an exact match.
# This applies the same matching behavior to Yazi's Z command and shell z command.
export YAZI_ZOXIDE_OPTS="--no-exact"

# Configure FZF to search with fd and display bat previews.
export FZF_DEFAULT_COMMAND="fd --type file --color=always"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'"

# Keep regular Tab for Zsh completions; use ~~ followed by Tab for FZF completion.
export FZF_COMPLETION_TRIGGER="${FZF_COMPLETION_TRIGGER:-~~}"
