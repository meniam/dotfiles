# Legacy dotfiles management commands.
alias dfupdate="~/.dotfiles/upgrade"
alias dfupgrade="~/.dotfiles/upgrade"
alias reload="cd ~/.dotfiles && ~/.dotfiles/reload && source ~/.zshrc && cd -"
alias update="cd ~/.dotfiles && ~/.dotfiles/upgrade && source ~/.zshrc && cd -"

# Navigate directories quickly.
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias www="cd ~/www"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"

# Make file operations interactive and provide concise directory listings.
alias cd='>/dev/null cd'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'
alias ls='ls --color=auto'
alias lla='ls --color=auto -laphc'

# Let eza's bundled theme control file colors instead of inherited LS_COLORS rules.
alias ll='env -u LS_COLORS -u EZA_COLORS eza --tree --level=1 --long --group --icons=always --group-directories-first'
alias ll1='env -u LS_COLORS -u EZA_COLORS eza --tree --level=1 --long --group --icons=always --group-directories-first'
alias ll2='env -u LS_COLORS -u EZA_COLORS eza --tree --level=2 --long --group --icons=always --group-directories-first'
alias du='du -h'
alias df='df -h'
alias grep='grep --color=auto'
alias less='less -R -M -X'

# Use FZF to select files and open the selected result in Midnight Commander.
alias p="fzf -m --bind ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all --no-sort --ansi --preview 'bat --color=always --style=numbers,header,grid --line-range :500 {}'"
alias e='mcedit $(p)'

# Shorten commonly used development and terminal commands.
alias g='git'
alias mux='tmuxinator'
alias t='tmux attach || tmux new-session'
alias tn='tmux new-session'
alias tc='tmux new-session -s'
alias tl='tmux list-sessions'
alias dc='docker-compose'
alias lzd='lazydocker'
alias pgt='pg_top -h localhost -U postgres'
alias pga='pg_activity -h localhost -U postgres'

# Inspect network details and format common time values.
alias myip="curl -s ipinfo.io | jq -r '.ip'"
alias myipl="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias speedtest='wget -O /dev/null http://speed.transip.nl/100mb.bin'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
alias week='date +%V'
alias epoch='date +%s'
alias timestamp='date "+%Y%m%d_%H%M%S"'
alias iso8601='date -u +"%Y-%m-%dT%H:%M:%SZ"'

# Create archives, inspect text, and generate random values.
alias targz='tar -czf'
alias untargz='tar -xzf'
alias zip='zip -r'
alias json='python3 -m json.tool'
alias qr='qrencode -t utf8'
alias password='openssl rand -base64 32'
alias pass='pwgen -1 -s -B 12'
alias wordcount="tr -s ' ' | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -nr"

# Provide system, configuration, and macOS convenience commands.
alias ctl='systemctl'
alias sudo='sudo '
alias type='type -a'
alias quit='exit'
alias zshconfig='vim ~/.zshrc'
alias ohmyzsh='vim ~/.oh-my-zsh'
alias hosts='sudo mcedit /etc/hosts'
alias chrome='open /Applications/Google\ Chrome.app'
alias afk='pmset displaysleepnow'
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias grip='grip -b'
alias dns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias hs='cd /Users/eugene/www/myazin/hs'
alias hsv='cd /Users/eugene/www/myazin/hs && code .'

alias bmd='bat -l md'