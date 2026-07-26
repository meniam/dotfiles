# Show the user, host, current directory, and Git status in the prompt.
if (( EUID == 0 )); then
  PROMPT='%B%F{red}%n%f%F{yellow}@%f%F{cyan}%m %f%F{yellow}%d%f%b'
else
  PROMPT='%B%F{green}%n%f%F{yellow}@%f%F{cyan}%m %f%F{yellow}%d%f%b'
fi
PROMPT+='$(git_prompt_info)'
PROMPT+=' %B%F{magenta}$%f%b '
