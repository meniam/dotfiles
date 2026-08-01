# Render the current Git branch and mark repositories with uncommitted changes.
git_prompt_info() {
  local branch
  branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null)" || \
    branch="$(command git rev-parse --short HEAD 2>/dev/null)" || return 0

  if [[ -n "$(command git status --porcelain 2>/dev/null)" ]]; then
    print -n -- " %B%F{blue}git:(%F{red}${branch}%F{blue}) %F{yellow}✗%f%b"
  else
    print -n -- " %B%F{blue}git:(%F{red}${branch}%F{blue})%f%b"
  fi
}

# Launch Yazi and change the current shell directory to the location selected in it.
# Use \`y\` or \`н\` with a Russian keyboard layout; all arguments are forwarded to Yazi.
y() {
  local yazi_cwd_file cwd yazi_status

  yazi_cwd_file="$(command mktemp -t 'yazi-cwd.XXXXXX')" || return 1
  command yazi "$@" --cwd-file="$yazi_cwd_file"
  yazi_status=$?

  if [[ -r "$yazi_cwd_file" ]]; then
    cwd="$(<"$yazi_cwd_file")"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  fi

  command rm -f -- "$yazi_cwd_file"
  return "$yazi_status"
}
alias н='y'

# Show a compact weather forecast for a city, defaulting to Voronezh.
# Run 'weather Moscow' for a named city, or 'weather' for Voronezh.
weather() {
  local weather_location="${1:-Voronezh}"
  local weather_url="https://wttr.in/${weather_location}?m&lang=ru"

  command curl --fail --location --silent --show-error "$weather_url"
}

# Attach to a named Tmux session or create a four-pane backup workspace.
ta() {
  local name="${1:-backup}"

  if tmux has-session -t "$name" 2>/dev/null; then
    if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "$name"
    else
      tmux attach -t "$name"
    fi
    return
  fi

  if [[ "$name" != "backup" ]]; then
    tmux new-session -s "$name"
    return
  fi

  tmux new-session -d -s "$name" -n main 'exec ${SHELL:-/bin/zsh} -l' 2>/dev/null || \
    tmux new-session -d -s "$name" -n main

  local top_left
  top_left="$(tmux display-message -p -t "$name":main '#{pane_id}')" || return 1

  local top_right bottom_left bottom_right
  top_right="$(tmux split-window -h -t "$top_left" -P -F '#{pane_id}')" || return 1
  bottom_left="$(tmux split-window -v -t "$top_left" -P -F '#{pane_id}')" || return 1
  bottom_right="$(tmux split-window -v -t "$top_right" -P -F '#{pane_id}')" || return 1

  tmux select-layout -t "$name":main tiled
  tmux send-keys -t "$top_left" 'clear' C-m
  tmux send-keys -t "$top_right" 'docker ps' C-m
  tmux send-keys -t "$bottom_left" 'pydf | grep -v /var/' C-m
  tmux send-keys -t "$bottom_right" 'lazydocker' C-m

  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$name"
  else
    tmux attach -t "$name"
  fi
}

# Generate a UUID-like value when uuidgen is unavailable.
uuid() {
  od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}'
}

# Create a directory and change into it. With several arguments every directory
# is created and the shell moves into the last one.
tkdir() {
  if (( $# == 0 )); then
    print -u2 -- 'tkdir: pass a directory name'
    return 2
  fi

  command mkdir -p -- "$@" && builtin cd -- "${@[-1]}"
}

# List processes whose command line matches a pattern, with the match
# highlighted. The second grep drops the pipeline's own grep from the result.
pid() {
  if (( $# == 0 )); then
    print -u2 -- 'pid: pass a pattern'
    return 2
  fi

  command ps -ax -o 'pid,command' \
    | command grep --color=always -- "$1" \
    | command grep -v -- ' grep '
}

# Print a random string. First argument is the length (32 by default), second is
# a tr(1) character set. Reads from /dev/urandom until enough characters of the
# set have appeared, so a narrow set still produces the full length.
random() {
  local length="${1:-32}"
  local charset="${2:-A-Za-z0-9!#$%&()*+,-./:;<=>?@[]^_\`{|}~}"

  LC_ALL=C command tr -dc -- "$charset" </dev/urandom | command head -c "$length"
  print
}

# Print the defined aliases as an aligned two-column table, names highlighted.
# The ### separator is an arbitrary marker for column(1): an alias body can
# contain any character, so splitting on = or a space would break the layout.
alias-list() {
  local name_colour=$'\e[1;34m' reset=$'\e[0m'

  alias | sort \
    | command sed -E "s|^([^=]*)=(.*)|${name_colour}\1###${reset}\2|" \
    | command column -s '###' -t
}

# Print the shell's command hash table the same way: resolved commands and the
# paths they point at.
hash-list() {
  local name_colour=$'\e[1;34m' reset=$'\e[0m'

  hash | command grep -v -e '^hashx=' | sort \
    | command sed -E "s|^([^=]*)=(.*)|${name_colour}\1${reset}=\2|" \
    | command column -s '=' -t
}

# Print a highlighted comment line surrounded by blank lines. Useful for marking
# sections in the output of a long session or a recorded terminal.
annotate() {
  local bold=$'\e[1m' reset=$'\e[0m'

  print
  print -- "${bold}# $*${reset}"
  print
}

# Send an HTTP request file through httpyac and show the response body as
# highlighted JSON.
htt() {
  local tool
  for tool in httpyac jq bat; do
    if (( ! $+commands[$tool] )); then
      print -u2 -- "htt: $tool is not installed"
      return 127
    fi
  done

  if (( $# == 0 )); then
    print -u2 -- 'htt: pass an .http request file'
    return 2
  fi

  command httpyac "$1" --json -a \
    | command jq -r '.requests[0].response.body' \
    | command jq \
    | command bat --language=json
}

# Ask Pi a question about the current shell, passing the working directory and
# the ten most recent commands as context, and render the answer as Markdown.
# Run 'askPi why did the build fail' or use the '=' alias below.
askPi() {
  if (( ! $+commands[pi] )); then
    print -u2 -- 'askPi: pi is not installed'
    return 127
  fi

  if [[ -z "$*" ]]; then
    print -u2 -- 'askPi: pass a question, for example: = why did the build fail'
    return 2
  fi

  local -a recent_commands
  local -i event

  for (( event = HISTCMD - 1; event >= 1 && ${#recent_commands} < 10; event-- )); do
    [[ -n "${history[$event]}" ]] && recent_commands+=("${history[$event]}")
  done

  local -a prompt_lines
  prompt_lines=(
    '<system>'
    "Пользователь находится в директории: ${PWD}"
    'Последние 10 вводимых команд:'
  )

  local command_line
  for command_line in "${recent_commands[@]}"; do
    prompt_lines+=("- ${command_line}")
  done

  prompt_lines+=('</system>' '' '<question>' "$*" '</question>')

  local session_file="${HOME}/.pi/agent/sessions/console/session.jsonl"
  command mkdir -p -- "${session_file:h}" || return 1

  command pi --session "$session_file" -p "${(F)prompt_lines}" | command bat -l md
}

# Alias '=' to askPi. The `alias` builtin cannot take '=' as a name, so the
# alias is registered through the `aliases` associative array instead.
# `noglob` keeps question marks and asterisks in the question from being globbed.
aliases[=]='noglob askPi'
