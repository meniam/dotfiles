# Enable substitutions in the prompt for dynamic segments such as Git status.
setopt prompt_subst

# Use Emacs keybindings as the base keymap for interactive command editing.
bindkey -e

# Bind Home/End to line start/end. Emacs mode does not map these by default,
# so both the terminfo capability and common raw sequences are bound, since
# terminals (e.g. WezTerm) do not all agree on which one they send.
[[ -n "${terminfo[khome]:-}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]:-}" ]] && bindkey "${terminfo[kend]}" end-of-line
bindkey '\x1b[H' beginning-of-line
bindkey '\x1b[F' end-of-line
bindkey '\x1bOH' beginning-of-line
bindkey '\x1bOF' end-of-line
bindkey '\x1b[1~' beginning-of-line
bindkey '\x1b[4~' end-of-line

# Show and navigate completion candidates with consecutive Tab presses.
# Complete words at the cursor so command options and arguments remain discoverable.
setopt auto_list auto_menu complete_in_word always_to_end
