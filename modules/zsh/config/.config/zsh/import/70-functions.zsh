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
