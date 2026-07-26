# Enable substitutions in the prompt for dynamic segments such as Git status.
setopt prompt_subst

# Use Emacs keybindings as the base keymap for interactive command editing.
bindkey -e

# Show and navigate completion candidates with consecutive Tab presses.
# Complete words at the cursor so command options and arguments remain discoverable.
setopt auto_list auto_menu complete_in_word always_to_end
