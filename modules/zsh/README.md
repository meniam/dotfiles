# Zsh

An interactive Zsh configuration loaded from small, ordered files and extended
with Zinit-managed plugins.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none

The package manifests install Git and Zsh. `setup.sh` starts an interactive
command shell without allocating a TTY, with a two-minute timeout, to bootstrap
Zinit and warm the plugin cache. A timeout leaves plugin installation for the
first normal shell.

## Configuration layout

GNU Stow links `~/.zshrc` and the numbered imports below. `.zshrc` returns for
non-interactive shells and sources matching files in lexical order from
`${XDG_CONFIG_HOME:-$HOME/.config}/zsh/import/`.

| File | Responsibility |
| --- | --- |
| `00-options.zsh` | Interactive options and the Emacs keymap. |
| `10-history.zsh` | Shared history and cache creation under `${ZDOTDIR:-$HOME}/.cache/zsh/`. |
| `20-path.zsh` | Deduplicated, existence-checked command search paths. |
| `30-env.zsh` | Homebrew, Zoxide, Yazi, Eza, ripgrep, file-colour, and fzf environment settings. |
| `40-completion.zsh` | Zsh completion styles, compinit cache, Just completions, and the legacy fzf completion trigger. |
| `50-plugins.zsh` | Zinit bootstrap, plugins, selection behavior, and command-line clipboard support. |
| `60-aliases.zsh` | Navigation, file, development, system, archive, and convenience aliases. |
| `70-functions.zsh` | Git prompt state, Yazi directory changes, weather, tmux workspace, UUID, and Pi helpers. |
| `80-prompt.zsh` | User, host, working directory, and Git status prompt. |
| `90-local.zsh` | Loads the optional untracked `${ZDOTDIR:-$HOME}/.zshrc.local`. |

Keep new settings in the file responsible for their category so ordering stays
predictable. Machine-specific paths, hosts, credentials, and private settings
belong in `.zshrc.local`, not in tracked imports.

## Plugins and completion

Zinit is cloned into `${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git` and
loads:

- `zsh-completions`
- `zsh-autosuggestions`
- `fast-syntax-highlighting`
- `zsh-history-substring-search`
- `zsh-shift-select`

Completion uses a cached `.zcompdump`, case-insensitive matching, grouped menu
selection, generated Just completions, and the package-manager-specific fzf
completion script. Regular Tab remains Zsh completion; `~~` followed by Tab is
the configured fzf completion trigger.

## Cross-module integration

- Zoxide is initialized when available, and Yazi receives fuzzy Zoxide options.
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
