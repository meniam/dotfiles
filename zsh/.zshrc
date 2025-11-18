export PATH=$HOME/.bin:/opt/homebrew/opt/coreutils/libexec/gnubin:~/.local/bin/:/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/postgresql@16/bin:$PATH
export PATH="/opt/homebrew/opt/php@8.3/bin:$PATH"
export PATH="/opt/homebrew/opt/php@8.3/sbin:$PATH"

ZSH_CUSTOM=$HOME/.config/zsh

export ZSH="$HOME/.oh-my-zsh"
export DOT_BIN="$HOME/.bin"
export CONFIG_ZSH="$HOME/.config/zsh"
export DOCKER_CLI_HINTS=false

ZSH_THEME="meniam"

zstyle ':omz:update' mode auto      # update automatically without asking
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?

plugins=(
macos
symfony2
colorize
github
brew
git
docker
docker-compose
zjump
zsh-autosuggestions
zsh-syntax-highlighting
zsh-history-substring-search
z
)

source $ZSH/oh-my-zsh.sh

# User configuration
source "$CONFIG_ZSH/modules/general.zsh"
source "$CONFIG_ZSH/modules/path.zsh"
source "$CONFIG_ZSH/modules/completion.zsh"
source "$CONFIG_ZSH/modules/fzf-completion.zsh"
source "$CONFIG_ZSH/modules/fzf-bindings.zsh"
source "$CONFIG_ZSH/modules/history.zsh"
source "$CONFIG_ZSH/modules/plugins.zsh"

if [[ ! -n "$TMUX" ]]; then
source "$CONFIG_ZSH/modules/hello.zsh"
fi

source "$HOME/.aliases"

# cd ~
# echo $START

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi

if [ -f "/root/.acme.sh/acme.sh.env" ]; then
    source "/root/.acme.sh/acme.sh.env"
fi

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# export PATH="/opt/homebrew/opt/php@8.3/bin:$PATH"
# export PATH="/opt/homebrew/opt/php@8.3/sbin:$PATH"
# # The following lines have been added by Docker Desktop to enable Docker CLI completions.
# fpath=(/Users/eugene/.docker/completions $fpath)
# autoload -Uz compinit
# compinit
# # End of Docker CLI completions
#
# # Added by LM Studio CLI (lms)
# export PATH="$PATH:/Users/eugene/.cache/lm-studio/bin"

