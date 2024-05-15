ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_MAXLENGTH=300

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6d7072,bg=black,underline"

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=default,fg=magenta,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=default,fg=black,bold'
HISTORY_SUBSTRING_SEARCH_FUZZY='true'

bindkey '^[[A' history-substring-search-up    # arrow-up
bindkey '^[[B' history-substring-search-down  # arrow-down
[ ${key[Up]} ]   && bindkey "${key[Up]}"   history-substring-search-up    # arrow-up
[ ${key[Down]} ] && bindkey "${key[Down]}" history-substring-search-down  # arrow-down
