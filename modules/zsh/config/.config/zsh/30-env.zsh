# Hide Homebrew environment-variable hints without disabling automatic updates.
export HOMEBREW_NO_ENV_HINTS=1

# UTF-8 everywhere. macOS terminals export LANG on their own, but a container,
# `ssh -T`, cron, and `docker build` do not: without it sort order, ls, and less
# fall back to the POSIX locale and mangle non-ASCII output.
#
# LC_ALL is set alongside it, as it was in the previous configuration. Note that
# ssh forwards both (SendEnv LANG LC_*), so a server without this locale answers
# with `setlocale: LC_ALL: cannot change locale`. Drop the LC_ALL line if that
# warning shows up more often than the guarantee is worth.
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# less as the pager, with flags that matter for short output:
#   -F  quit immediately when the text fits on one screen
#   -R  pass colour escapes through instead of printing them literally
#   -X  do not switch to the alternate screen, so the output stays in the
#       scrollback after less exits
export PAGER='less'
export LESS='-FRX'

# Colourise man pages. bat renders them with the same theme as everything else
# it displays; `col -bx` first turns the overstrike sequences groff emits into
# plain text, which bat cannot read on its own. MANROFFOPT=-c is required by
# groff 1.23 and later, where the default output would reach col garbled; macOS
# ignores it harmlessly.
#
# bat comes from the fs module, which this one does not depend on, so the
# fallback dresses less itself: LESS_TERMCAP_md starts bold text, us starts
# underlined text, and ue ends it. Literal escapes rather than $fg_bold[...],
# which would need `autoload -U colors` loaded first.
if (( $+commands[bat] )); then
  export MANROFFOPT='-c'
  export MANPAGER="sh -c 'col -bx | bat --language man --style plain'"
else
  export LESS_TERMCAP_md=$'\e[1;32m'
  export LESS_TERMCAP_us=$'\e[36m'
  export LESS_TERMCAP_ue=$'\e[0m'
fi

# Editor used by everything that honours EDITOR/VISUAL: Git commit messages and
# interactive rebase, `crontab -e`, less's `v`, fzf's edit binding. Nothing set
# it before, so Git fell through to `vi`.
#
# Resolved here rather than as `core.editor` in the git module: that module does
# not depend on nvim, so hardcoding it there breaks Git on a machine that
# installed git without nvim. The loop degrades to whatever is present instead.
for zsh_editor_candidate in nvim vim vi; do
  if (( $+commands[$zsh_editor_candidate] )); then
    export EDITOR="$zsh_editor_candidate"
    export VISUAL="$zsh_editor_candidate"
    break
  fi
done
unset zsh_editor_candidate

# Micro renders 24-bit colour only when this is set; without it the Catppuccin
# scheme the must-have module stows is quantized to the 256-colour palette. It
# is gated on the terminal advertising true colour, because on a terminal that
# does not the same flag makes Micro emit colours it cannot show.
if [[ "${COLORTERM:-}" == (truecolor|24bit) ]]; then
  export MICRO_TRUECOLOR=1
fi

# Initialize Zoxide's directory-jumping command and record directory changes.
# Type 'z <query>' to jump to a frequently used directory matching the query.
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# Switch tool versions per directory. mise rewrites PATH on every prompt from
# the mise.toml, .tool-versions, or .nvmrc that applies to the current
# directory; a directory that pins nothing is left alone, so the Homebrew or
# APT toolchain stays in charge outside projects.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# Load an approved .envrc when entering a directory and unload it when leaving.
# direnv prepends itself to precmd_functions regardless of where it is hooked,
# so mise runs after it and keeps the last word on PATH. A variable set by both
# therefore takes the mise value; leave tool paths to mise and .envrc to
# project variables.
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# Keep Yazi's Zoxide picker fuzzy instead of requiring an exact match.
# This applies the same matching behavior to Yazi's Z command and shell z command.
export YAZI_ZOXIDE_OPTS="--no-exact"

# Load the eza theme from the stowed XDG configuration directory on every platform.
export EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eza"

# Point ripgrep at the configuration file stowed by the fs module; ripgrep reads
# no configuration file unless this variable names one. The existence check is
# required rather than tidy: when the variable points at a missing file, every
# single rg invocation fails with a read error, which is what a shell-only
# install without the fs module would produce.
rg_config_file="${XDG_CONFIG_HOME:-$HOME/.config}/ripgrep/ripgreprc"
[[ -r "$rg_config_file" ]] && export RIPGREP_CONFIG_PATH="$rg_config_file"
unset rg_config_file

# Load the startup file stowed by the python module in interactive interpreters
# and keep REPL history in the XDG cache. Both variables are set together on
# purpose: a PYTHONSTARTUP naming a missing file makes every session start with a
# traceback, and PYTHON_HISTORY pointing outside $HOME only keeps history because
# that startup file creates the directory first. PYTHON_HISTORY is honoured by
# Python 3.13 and later; older interpreters keep using ~/.python_history.
python_startup_file="${XDG_CONFIG_HOME:-$HOME/.config}/python/startup.py"
if [[ -r "$python_startup_file" ]]; then
  export PYTHONSTARTUP="$python_startup_file"
  export PYTHON_HISTORY="${XDG_CACHE_HOME:-$HOME/.cache}/python/history"
fi
unset python_startup_file

# Configure FZF to search with fd and display bat previews.
export FZF_DEFAULT_COMMAND="fd --type file --color=always"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}' --bind='alt-j:preview-down,alt-k:preview-up,ctrl-alt-j:preview-page-down,ctrl-alt-k:preview-page-up'"

# Options for the Alt+C widget bound in 50-plugins.zsh, which changes to a
# directory below the current one. Directories are the candidates here, so the
# preview lists their contents instead of running the file preview inherited
# from FZF_DEFAULT_OPTS. eza comes from the fs module; ls covers a shell-only
# install.
export FZF_ALT_C_COMMAND="fd --type directory --color=always"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} 2>/dev/null || ls -A {}'"

# Options for the Ctrl+R widget bound in 50-plugins.zsh, which searches the
# shell history. Its candidates are commands rather than paths, so the inherited
# bat preview would report a missing file for every line; fzf applies the last
# --preview it is given, and this one echoes the selected command without its
# history index. The pane starts hidden because a wrapped copy of the highlighted
# line is only worth the space for a command too long to read inline.
export FZF_CTRL_R_OPTS="--preview 'printf %s {2..}' --preview-window 'down:3:hidden:wrap' --bind 'ctrl-/:toggle-preview'"

# Keep regular Tab for Zsh completions; use ~~ followed by Tab for FZF completion.
export FZF_COMPLETION_TRIGGER="${FZF_COMPLETION_TRIGGER:-~~}"
