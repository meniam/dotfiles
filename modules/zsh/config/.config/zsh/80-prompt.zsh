# Powerlevel10k owns the prompt. Its settings live in ~/.config/zsh/p10k.zsh and
# are sourced by .zshrc, the only file the configuration wizard scans; see the
# module README before moving that source line here.
#
# What remains here is the fallback for a shell without the theme: Zinit missing,
# or its first clone not finished yet. It shows user, host, working directory, and
# Git status from git_prompt_info in 70-functions.zsh.
if (( ! $+functions[p10k] )); then
  if (( EUID == 0 )); then
    PROMPT='%B%F{red}%n%f%F{yellow}@%f%F{cyan}%m %f%F{yellow}%d%f%b'
  else
    PROMPT='%B%F{green}%n%f%F{yellow}@%f%F{cyan}%m %f%F{yellow}%d%f%b'
  fi
  PROMPT+='$(git_prompt_info)'
  PROMPT+=' %B%F{magenta}$%f%b '
fi
