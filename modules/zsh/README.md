# Zsh

An interactive Zsh configuration loaded from small, ordered files and extended
with Zinit-managed plugins.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none

The package manifests install Git and Zsh. `setup.sh` starts an interactive
command shell without allocating a TTY, with a three-minute timeout, to bootstrap
Zinit and warm the plugin cache, including the Powerlevel10k clone and its
`gitstatusd` binary. A timeout leaves plugin installation for the first normal
shell.

## Configuration layout

GNU Stow links `~/.zshrc`, the numbered imports below, and the prompt settings in
`~/.config/zsh/p10k.zsh`. `.zshrc` replays the Powerlevel10k instant prompt,
returns for non-interactive shells, sources matching files in lexical order from
`${XDG_CONFIG_HOME:-$HOME/.config}/zsh/import/`, and finally sources the prompt
settings.

| File | Responsibility |
| --- | --- |
| `00-options.zsh` | Interactive options and the Emacs keymap. |
| `10-history.zsh` | Shared history and cache creation under `${ZDOTDIR:-$HOME}/.cache/zsh/`. |
| `20-path.zsh` | Deduplicated, existence-checked command search paths. |
| `30-env.zsh` | `EDITOR`/`VISUAL`, Homebrew, Zoxide, mise, direnv, Yazi, Eza, ripgrep, Python REPL, file-colour, and fzf environment settings. |
| `40-completion.zsh` | Zsh completion styles, compinit cache, Just completions, and the legacy fzf completion trigger. |
| `50-plugins.zsh` | Zinit bootstrap, plugins, selection behavior, and command-line clipboard support. |
| `60-aliases.zsh` | Navigation, file, development, system, archive, and convenience aliases. |
| `70-functions.zsh` | Git prompt state, Yazi directory changes, weather, tmux workspace, UUID, and Pi helpers. |
| `80-prompt.zsh` | Fallback prompt for a shell where the theme did not load. |
| `90-local.zsh` | Loads the optional untracked `${ZDOTDIR:-$HOME}/.zshrc.local`. |

`p10k.zsh` sits outside `import/` on purpose: the loop matches only
`[0-9][0-9]-*.zsh`, and the file is sourced from `.zshrc` instead. See
[Prompt](#prompt) for why that source line cannot move into `80-prompt.zsh`.

Keep new settings in the file responsible for their category so ordering stays
predictable. Machine-specific paths, hosts, credentials, and private settings
belong in `.zshrc.local`, not in tracked imports.

## Plugins and completion

Zinit is cloned into `${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git` and
loads:

- `powerlevel10k` (loaded first; see [Prompt](#prompt))
- `zsh-completions`
- `zsh-autosuggestions`
- `fast-syntax-highlighting`
- `zsh-history-substring-search`
- `zsh-shift-select`

Completion uses a cached `.zcompdump`, case-insensitive matching, grouped menu
selection, generated Just completions, and the package-manager-specific fzf
completion script. Regular Tab remains Zsh completion; `~~` followed by Tab is
the configured fzf completion trigger.

## Prompt

[Powerlevel10k](https://github.com/romkatv/powerlevel10k) draws the prompt. Zinit
loads it as the first plugin and `.zshrc` sources its settings last.

The current settings come from `p10k configure` with the lean style, Nerd Font v3
glyphs, 24-hour time, and a two-line prompt joined by a dotted gap: OS icon,
directory, and Git state on the first line, `❯` on the second, and a right prompt
that shows a non-zero exit code, command duration, background jobs, the active
tool-version and cloud contexts, and a clock. Git state comes from `gitstatusd`, a
daemon the theme downloads on first use, which is what keeps the status cheap in a
large repository.

### The settings file

`~/.config/zsh/p10k.zsh` is a single tracked file, stowed from this module, and it
is what `p10k configure` overwrites: the last line of the file declares
`POWERLEVEL9K_CONFIG_FILE` as its own path, and the wizard resolves that symlink
before writing. A wizard run therefore edits the repository directly, and
`git diff` is the review step before committing the new prompt.

Consequences worth knowing:

- The wizard rewrites the file in full, so hand-made edits inside it survive only
  until the next `p10k configure`. Prefer running the wizard.
- Machine-specific prompt tweaks belong in the untracked
  `${ZDOTDIR:-$HOME}/.zshrc.local`, which `90-local.zsh` sources after everything
  else.
- After editing the file by hand, run `p10k reload` or start a new shell;
  `POWERLEVEL9K_DISABLE_HOT_RELOAD=true` keeps the theme from re-reading its
  variables on every prompt.

The source line lives in `.zshrc` rather than in `80-prompt.zsh` because the
wizard scans only `~/.zshrc`. It looks for one of a few literal forms, including
`source "$POWERLEVEL9K_CONFIG_FILE"` and the instant-prompt block at the top of
the file, and prepends or appends its own copy of anything it does not find.
Keeping both in the form upstream recognizes is what makes a repeated
`p10k configure` leave `.zshrc` alone.

### Fonts and instant prompt

`POWERLEVEL9K_MODE=nerdfont-v3` expects a Nerd Font. The WezTerm and Kitty
configurations in the `desktop` module use FiraCode Nerd Font Mono; the font
itself is not installed by this repository. On a terminal without a patched font,
rerun `p10k configure` there and pick the ASCII character set.

`.zshrc` replays the cached instant prompt before loading anything else, so a
first prompt appears while plugins and the mise and direnv hooks are still
initializing. The cache lives in `${XDG_CACHE_HOME:-$HOME/.cache}` and is written
by the theme, so the block does nothing until the theme has run once. The
generated setting is `POWERLEVEL9K_INSTANT_PROMPT=verbose`, which prints a warning
when anything else writes to the terminal during startup — most often Zinit
cloning a plugin on a first run. `quiet` suppresses that warning and `off`
disables instant prompt; both are wizard options.

### Fallback

When Zinit is missing, or its first clone has not finished, `$functions[p10k]`
does not exist and `80-prompt.zsh` falls back to the previous hand-written
prompt: user, host, working directory, and `git_prompt_info` from
`70-functions.zsh`.

## Cross-module integration

- Zoxide is initialized when available, and Yazi receives fuzzy Zoxide options.
- mise is activated when the `mise` module installed it, which switches tool
  versions per directory. Activation is part of the interactive configuration
  only, so non-interactive shells keep the plain `PATH`.
- direnv is hooked when the `must-have` module installed it. direnv prepends
  itself to `precmd_functions`, so mise's hook runs after it and keeps the last
  word on `PATH`; a variable set in both `mise.toml` and `.envrc` ends up with
  the mise value.
- Eza reads the theme from the `fs` module through `EZA_CONFIG_DIR`.
- ripgrep reads the `fs` module's configuration only when that file exists.
- `PYTHONSTARTUP` and `PYTHON_HISTORY` are exported only when the `python`
  module's startup file exists, which moves REPL history to `~/.cache/python/`.
- fzf defaults use fd for discovery and bat for previews.
- the `y` function runs Yazi and changes the shell to Yazi's final directory.
- tmux, Docker, Git, filesystem, and media shortcuts become useful when their
  corresponding modules are installed; unavailable commands are not installed
  by this module automatically.

The `askPi` helper sends the current working directory, up to ten recent shell
commands, and the supplied question to the external `pi` command, then renders
its response with bat. Review shell history for secrets before invoking it.

The probe checks only that Zsh is available. Plugin, completion, and
cross-module command availability do not affect `./install --status`.
