# Load the numbered Zsh configuration modules for interactive shells only.
[[ -o interactive ]] || return

# Load modules from the XDG configuration directory.
zsh_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/import"

for zsh_config_file in "$zsh_config_dir"/[0-9][0-9]-*.zsh(N); do
  source "$zsh_config_file"
done

unset zsh_config_dir zsh_config_file
