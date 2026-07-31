# Enable Powerlevel10k instant prompt: replay the prompt cached during the
# previous session so plugin loading and the mise and direnv hooks happen behind a
# visible prompt instead of an empty terminal. It must stay above everything that
# prints or reads from the terminal. The cache is written by the theme, so without
# Powerlevel10k the file never exists and this block does nothing.
#
# Keep the literal form: `p10k configure` scans ~/.zshrc for exactly this block
# and prepends its own copy when it does not find it.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load the numbered Zsh configuration modules for interactive shells only.
[[ -o interactive ]] || return

# Load modules from the XDG configuration directory.
zsh_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/import"

for zsh_config_file in "$zsh_config_dir"/[0-9][0-9]-*.zsh(N); do
  source "$zsh_config_file"
done

unset zsh_config_dir zsh_config_file

# Prompt settings, generated and overwritten in full by `p10k configure`. They are
# sourced here rather than from 80-prompt.zsh because the wizard scans only
# ~/.zshrc, and `source "$POWERLEVEL9K_CONFIG_FILE"` is one of the forms it
# recognizes; without a recognized line every wizard run appends another one.
# The file re-declares POWERLEVEL9K_CONFIG_FILE at its end, which is what tells
# the wizard where to write.
typeset -g POWERLEVEL9K_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/p10k.zsh"
[[ ! -r "$POWERLEVEL9K_CONFIG_FILE" ]] || source "$POWERLEVEL9K_CONFIG_FILE"
