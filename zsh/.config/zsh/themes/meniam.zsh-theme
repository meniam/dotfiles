if [[ $UID == 0 || $EUID == 0 ]]; then
PROMPT='%{$fg_bold[red]%}%n%{$reset_color%}%{$fg_bold[yellow]%}@%{$reset_color%}%{$fg_bold[cyan]%}%m %{$reset_color%}%{$fg_bold[yellow]%}%d%{$reset_color%}'
else
PROMPT='%{$fg_bold[green]%}%n%{$reset_color%}%{$fg_bold[yellow]%}@%{$reset_color%}%{$fg_bold[cyan]%}%m %{$reset_color%}%{$fg_bold[yellow]%}%d%{$reset_color%}'
fi

PROMPT+='$(git_prompt_info)'
PROMPT+=" %{$fg_bold[magenta]%}$%{$reset_color%} "

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"