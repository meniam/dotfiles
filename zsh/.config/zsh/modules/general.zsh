autoload -U colors && colors
autoload -U keeper

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

setopt MULTIOS  # enable multi output streams
setopt NOTIFY # Report the status of background jobs immediately, rather than waiting until just before printing a prompt.
setopt INTERACTIVE_COMMENTS # Allowes to use #-sign as comment within commandline
export WORDCHARS='' # threat every special charater as word delimiter

# defaut editor
bindkey -e # ensure emacs mode
export VISUAL='mcedit'
export EDITOR='mcedit'
export PAGER='less'

# colorize file system view
# http://www.bigsoft.co.uk/blog/2008/04/11/configuring-ls_colors
# Images = 35 Purple
# Archive = 94 Light blue
# Text = 32 Green
export LS_COLORS="rs=0:di=01;36:ln=00;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=43;30:st=37;44:ex=01;32:*Makefile=90:*LICENSE=90:*.bak=90:*.lock=90:*.php=32:*.js=32:*.yml=93:*.conf=93:*.yaml=93:*.md=32:*.json=32:*.pdf=32:*.txt=32:*.tar=94:*.tgz=94:*.arj=94:*.taz=94:*.lzh=94:*.lzma=94:*.tlz=94:*.txz=94:*.zip=94:*.z=94:*.Z=94:*.dz=94:*.gz=94:*.lz=94:*.xz=94:*.bz2=94:*.bz=94:*.tbz=94:*.tbz2=94:*.tz=94:*.deb=94:*.rpm=94:*.jar=94:*.rar=94:*.ace=94:*.zoo=94:*.cpio=94:*.7z=94:*.rz=94:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:"
# colorize file system view (macOS)
export LSCOLORS="Exfxcxdxbxegedabagacad"

# support colors in less
export LESS_TERMCAP_md=$(printf "${fg_bold[green]}") \
export LESS_TERMCAP_us=$(printf "${fg[cyan]}") \
export LESS_TERMCAP_ue=$(printf "$reset_color")

### fzf configuration
if [ $commands[fzf] ]
then
  export FZF_DEFAULT_OPTS='
    --color fg:-1,bg:-1,hl:5,fg+:3,bg+:-1,hl+:5
    --color info:42,prompt:-1,spinner:42,pointer:51,marker:33
    --exact
    --ansi'
  if [ $commands[fd] ]
  then
    export FZF_DEFAULT_COMMAND="fd -c always"
  fi
fi


################################################################################
####### Utils ##################################################################
################################################################################

function prepend-path {
  [ -d $1 ] && PATH="$1:$PATH"
}

function pid {
  ps -ax -o "pid,command" \
  | grep --color=always "$1" \
  | grep -v " grep "
}

# colorized alias list
function alias-list {
  alias | sort \
  | sed -E -e "s|^([^=]*)=(.*)|${fg_bold[blue]}\1###${fg[white]}\2${reset_color}|" \
  | column -s '###' -t
}

# colorized command list
function hash-list {
  hash | grep -v -e 'hashx=' | sort \
  | sed -E -e "s|^([^=]*)(=.*)|${fg_bold[blue]}\1${reset_color}\2|" \
  | column -s '=' -t
}

# make directory and jump into it
function tkdir { mkdir $@ && cd $_ }

# Print line annotation with comment
function annotate {
  local comment=$1
  echo
  echo "${bg[grey]}${fg_bold[default]}\e[2K# ${comment}${reset_color}"
  echo
}

# executes given commad in every sub directory
function workspace {
  local workspace=$PWD
  local dir
  for dir in */; do
    ( cd $dir && printf "\\e[34m${PWD#$workspace/}:\\e[39m\\n" && eval "$@" && echo )
  done
}

# generate random characters
function random {
  local character_count=${1:-32}
  local character_set=${2:-'A-Za-z0-9!#$%&()*+,-./:;<=>?@[]^_`{|}~'}
  head /dev/urandom | LC_ALL=C tr -dc $character_set | fold -w $character_count | head -1
}

# print weather forecast for current location to prompt
function weather {
  curl "https://wttr.in/${1:-Воронеж}?m&lang=ru"
}

# colorized man
function man {
  LESS_TERMCAP_md=$(printf "${fg_bold[green]}") \
  LESS_TERMCAP_us=$(printf "${fg[cyan]}") \
  LESS_TERMCAP_ue=$(printf "$reset_color") \
  PAGER="${commands[less]:-$PAGER}" \
  _NROFF_U=1 \
     command man "$@"
}

# colorized diff
function diff {
  command diff "$@" | sed \
    -e "s|^\(<.*\)|${fg[red]}\1$reset_color|" \
    -e "s|^\(>.*\)|${fg[green]}\1$reset_color|" \
    -e "s|^\([a-z0-9].*\)|${fg_bold[cyan]}\1$reset_color|" \
    -l
  return ${pipestatus[1]}
}

################################################################################
####### Key Bindings ###########################################################
################################################################################

# Edit the current command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# IntelliJ Bindings
if [[ $TERMINAL_EMULATOR == 'JetBrains-JediTerm' ]]
then
  bindkey "^[^[[D" beginning-of-line
  bindkey "^[^[[C" end-of-line
fi
