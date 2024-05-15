#! /bin/bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then

    apt install fzf tilde micro vim imagemagick mc htop wget curl stow tmux net-utils

elif [[ "$OSTYPE" == "darwin"* ]]; then

    brew install fzf micro

else
    echo 'Unknown OS!'
    exit
fi

[ ! -d ${ZSH_CUSTOM:-~/.config/zsh}/plugins/zjump ] && git clone https://github.com/qoomon/zjump ${ZSH_CUSTOM:-~/.config/zsh}/plugins/zjump
[ ! -d ${ZSH_CUSTOM:-~/.config/zsh}/plugins/zsh-history-search ] && git clone https://github.com/qoomon/zsh-history-search ${ZSH_CUSTOM:-~/.config/zsh}/plugins/zsh-history-search
[ ! -d ${ZSH_CUSTOM:-~/.config/zsh}/plugins/zsh-syntax-highlighting ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.config/zsh}/plugins/zsh-syntax-highlighting
[ ! -d ${ZSH_CUSTOM:-~/.config/zsh}/plugins/zsh-autosuggestions ] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.config/zsh}/plugins/zsh-autosuggestions
[ ! -d ${ZSH_CUSTOM:-~/.config/zsh}/plugins/zsh-history-substring-search ] && git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.config/zsh}/plugins/zsh-history-substring-search
