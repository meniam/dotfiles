export PATH=$HOME/.bin:/opt/homebrew/opt/coreutils/libexec/gnubin:/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH

ZSH_CUSTOM=$HOME/.config/zsh

export ZSH="$HOME/.oh-my-zsh"
export DOT_BIN="$HOME/.bin"
export CONFIG_ZSH="$HOME/.config/zsh"

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

if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi

if [ -f "/root/.acme.sh/acme.sh.env" ]; then
    source "/root/.acme.sh/acme.sh.env"
fi

