# Enable substitutions in the prompt for dynamic segments such as Git status.
setopt prompt_subst

# Use Emacs keybindings as the base keymap for interactive command editing.
bindkey -e

# Treat `#` as a comment on the interactive command line too, not only in
# scripts. Without it a command pasted together with its trailing comment fails
# with `zsh: bad pattern: #`. Off by default in zsh.
setopt interactive_comments

# Which characters count as part of a word for Ctrl+W, Alt+B, Alt+F and Alt+D.
# This is the zsh default with `/` removed, so a word boundary falls on every
# path separator: Ctrl+W then deletes the last segment of ~/src/project/file.md
# instead of the whole path. Everything else keeps the default behaviour.
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# Ctrl+X Ctrl+E opens the current command line in $EDITOR and puts the result
# back when the editor exits. The way to fix a long pipeline or a multi-line
# loop without retyping it. 30-env.zsh resolves EDITOR.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Bind Home/End to line start/end. Emacs mode does not map these by default,
# so both the terminfo capability and common raw sequences are bound, since
# terminals (e.g. WezTerm) do not all agree on which one they send.
[[ -n "${terminfo[khome]:-}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]:-}" ]] && bindkey "${terminfo[kend]}" end-of-line
bindkey '\x1b[H' beginning-of-line
bindkey '\x1b[F' end-of-line
bindkey '\x1bOH' beginning-of-line
bindkey '\x1bOF' end-of-line
bindkey '\x1b[1~' beginning-of-line
bindkey '\x1b[4~' end-of-line

# Show and navigate completion candidates with consecutive Tab presses.
# Complete words at the cursor so command options and arguments remain discoverable.
setopt auto_list auto_menu complete_in_word always_to_end

# Sort glob matches by numeric value where they contain digits, so file2.log
# comes before file10.log instead of after it.
setopt numeric_glob_sort

# Match globs regardless of case: `ls *.JPG` also finds photo.jpg. macOS
# filesystems are case-insensitive anyway; on Linux this is a real difference.
setopt no_case_glob

# Extra pattern operators: ^ negates, ~ excludes, # repeats — `ls ^*.txt` lists
# everything that is not a .txt. Several plugins expect the option to be on.
# Only interactive shells are affected, so scripts relying on a literal # or ^
# keep working.
setopt extended_glob

# NULL_GLOB is deliberately left off. It would expand a pattern that matches
# nothing into nothing at all, which turns `rm *.bak` in a directory without
# backups into a bare `rm`.
