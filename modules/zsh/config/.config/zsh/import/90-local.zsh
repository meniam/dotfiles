# Load optional local overrides that are not managed by this repository.
zsh_local_config="${ZDOTDIR:-$HOME}/.zshrc.local"
[[ -r "$zsh_local_config" ]] && source "$zsh_local_config"
unset zsh_local_config
