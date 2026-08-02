# Zsh

An interactive Zsh configuration loaded from small, ordered files and extended
with Zinit-managed plugins.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none

The package manifests install Git and Zsh. `setup.sh` starts an interactive
command shell on a pseudo-terminal of its own through `script(1)`, with a
three-minute timeout, to bootstrap Zinit and clone every plugin, Powerlevel10k
included. Two details of that shell matter:

- The pseudo-terminal is what lets Zsh enable `zle`, which Powerlevel10k needs
  to start `gitstatusd`. Priming on a plain pipe reports that it cannot change
  the `zle` option and that gitstatus failed to initialize.
- `TERM` is defaulted to `xterm-256color` when the installer inherits none, as
  it does over SSH without a TTY. Without it the run stops after the
  Powerlevel10k clone and leaves the remaining plugins to the first shell.

The output of the priming run is shown only when it fails, and a timeout leaves
plugin installation for the first normal shell. The `gitstatusd` binary is not
part of it: Powerlevel10k fetches that when a prompt is first drawn.

## Configuration layout

GNU Stow links `~/.zshrc` and the numbered files below into
`${XDG_CONFIG_HOME:-$HOME/.config}/zsh/`. `.zshrc` replays the Powerlevel10k
instant prompt, returns for non-interactive shells, sources every matching file
in lexical order, and finally sources the prompt settings.

| File | Responsibility |
| --- | --- |
| `00-options.zsh` | Interactive options and the Emacs keymap. |
| `10-history.zsh` | Shared history and cache creation under `${ZDOTDIR:-$HOME}/.cache/zsh/`. |
| `20-path.zsh` | Deduplicated, existence-checked command search paths. |
| `30-env.zsh` | `EDITOR`/`VISUAL`, Homebrew, Zoxide, mise, direnv, Yazi, Eza, ripgrep, Python REPL, and fzf environment settings. |
| `32-colors.zsh` | The `LS_COLORS` palette and its BSD `LSCOLORS` counterpart. |
| `40-completion.zsh` | Zsh completion styles, compinit cache, Just completions, and the fzf integration lookup and completion trigger. |
| `50-plugins.zsh` | Zinit bootstrap, plugins, selection behavior, command-line clipboard support, and the fzf key bindings. |
| `60-aliases.zsh` | Navigation, file, development, system, archive, and convenience aliases. |
| `70-functions.zsh` | Git prompt state, Yazi directory changes, weather, tmux workspace, UUID, Pi helpers, and the SSH host picker. |
| `80-prompt.zsh` | Fallback prompt for a shell where the theme did not load. |
| `85-p10k.zsh` | Powerlevel10k settings, generated in full by `p10k configure`. |
| `90-local.zsh` | Loads the optional untracked `${ZDOTDIR:-$HOME}/.zshrc.local`. |

`85-p10k.zsh` is the one file the loop deliberately skips; `.zshrc` sources it
afterwards. See [Prompt](#prompt) for why that source line cannot move into the
loop or into `80-prompt.zsh`.

Other modules add their own fragments to the same directory instead of editing
anything here: `25-php.zsh` from `php85`, `26-rust.zsh` from `rust`, and
`35-ssh-agent.zsh` from `ssh`. Each is installed and removed with its own
module, so a machine without that module never sees the file.

`32-colors.zsh` has to load before `40-completion.zsh`, whose `list-colors`
zstyle reads `LS_COLORS`.

The module also stows the `dc` script into `~/.local/bin/`, a directory
`20-path.zsh` puts on `PATH`. See [Compose shortcut](#compose-shortcut).

Keep new settings in the file responsible for their category so ordering stays
predictable. Machine-specific paths, hosts, credentials, and private settings
belong in `.zshrc.local`, not in tracked files.

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
the configured fzf completion trigger. One exception: typing `ss` first
intercepts both Tab and Enter for the [SSH host picker](#ssh-host-picker)
below instead.

## fzf key bindings

`40-completion.zsh` resolves the directory that ships fzf's Zsh integration —
`$(brew --prefix fzf)/shell`, `/usr/share/doc/fzf/examples`, or
`/usr/share/fzf` — and `50-plugins.zsh` sources `key-bindings.zsh` from it after
the plugins, so nothing loaded later rebinds the keys:

| Key | Widget | Behavior |
| --- | --- | --- |
| Ctrl+R | `fzf-history-widget` | Fuzzy-searches the shell history and puts the chosen command on the line. Ctrl+/ toggles a wrapped preview of it. |
| Ctrl+T | `fzf-file-widget` | Inserts one or more paths from below the current directory at the cursor without running anything. Tab marks extra paths. |
| Alt+C | `fzf-cd-widget` | Changes to a directory below the current one. |

`30-env.zsh` supplies the discovery commands and per-widget options. Ctrl+T
inherits the fd file search and the bat preview from `FZF_DEFAULT_OPTS`, while
`FZF_ALT_C_*` switches to directories with an eza tree preview and
`FZF_CTRL_R_OPTS` replaces the file preview that history lines cannot use.

Two consequences on the key side:

- Ctrl+T replaces the Emacs `transpose-chars` binding.
- Alt+C reaches Zsh only from a terminal that sends Option as a real Alt
  modifier. The `desktop` module's WezTerm configuration does; Kitty on macOS
  does not until `macos_option_as_alt` is set, which costs the Option-composed
  characters.

Up and Down stay bound to `zsh-history-substring-search`, so the prefix search
and the fuzzy search coexist.

## SSH host picker

Typing `ss`, `ss ` (trailing space), or `ss <query>` and then pressing Tab or
Enter opens an fzf picker of SSH hosts instead of running a literal `ss`
command, completing normally, or submitting the line; `<query>` prefills fzf's
search. Selecting a host runs `ssh <host>`; canceling leaves the buffer as
typed.

Hosts come from `~/.ssh/config` and its Include'd `config.local` and
`config.d/*.conf` — the `ssh` module's layout for private, untracked per-host
configuration — skipping wildcard patterns such as `Host *`. A `Host` line
with several names is shown as `main-name (alias, alias)`; connecting strips
the parenthesized part and uses `main-name`.

`ssh-fzf-connect` wraps Tab: anything other than the trigger falls through to
`fzf-completion` (bound in `completion.zsh`), so the `~~` fuzzy-completion
trigger still works. `ssh-fzf-accept-line` wraps Enter (bound to `^M`) the
same way, falling through to the real `.accept-line` widget. Both widgets
require `fzf` to be on `PATH` and no-op to their normal behavior otherwise.

## Compose shortcut

`~/.local/bin/dc` shortens the Docker Compose commands typed most often. It is
a script rather than an alias because an alias cannot expand a subcommand into
different flags, and because it stays usable from scripts and other shells.

| Invocation | Runs |
| --- | --- |
| `dc` | An fzf picker of the commands below, then one of this project's services |
| `dc up [service...]` | `docker compose up -d --force-recreate [service...]` |
| `dc down [service...]` | `docker compose down [service...]` |
| `dc rebuild [service...]` | `docker compose build --pull --no-cache [service...]`, then the `up` above |
| `dc logs [service...]` | `docker compose logs -f [service...]` |
| `dc shell <service>` | `docker compose exec <service> bash`, falling back to `sh` |

`rebuild` combines a cacheless build with a refreshed base image, so the result
matches a build on a machine that never saw the project, and then replaces the
running containers with the images it just built. `shell` asks for `bash` and
falls back to `sh` inside the container, since many images ship only the
latter.

That list is the whole command set. Anything else is an error rather than a
pass-through to Compose, so `dc` stays a small, memorable set of shortcuts and
the rest of the CLI is typed as `docker compose ...`.

`dc` with no command opens an fzf picker of the five, with the matching
`~/.local/share/dc/docs/<command>.md` rendered beside the list by glow — one
page per command explaining what it does, what it leaves alone, and when to
reach for something else. Without glow the page is shown unrendered; without
the directory the preview pane is omitted.

The preview call carries two workarounds. `CLICOLOR_FORCE=1` restores the
palette glow drops to bold-only when its output is a pipe, which a preview
always is, and `</dev/null` keeps glow from preferring an empty stdin over the
file it was given. The theme is the `fs` module's `~/.config/glow/theme.json`,
passed per call because glow 2.1.2 reads neither its configuration file nor
`GLOW_STYLE`.

Choosing a command opens a second picker filled from
`docker compose config --services`, so it lists what the Compose file declares
rather than what happens to be running. Its first entry is `[ALL]`, which runs
the command against the whole project; it is where the cursor starts, so
running everything is one Enter, and it is still an explicit choice rather than
the result of selecting nothing. Tab marks several services. `shell` is the
exception: it takes exactly one service, so its picker is single-selection and
has no `[ALL]` entry. Square brackets cannot occur in a Compose service name,
so the entry cannot collide with a real one.

The service picker previews the configuration Compose resolved for the service
under the cursor — the merged result of every Compose file, override, and
variable, not the source text — highlighted by bat when it is installed.
`[ALL]` previews the whole project. The project is resolved once when the
picker opens and cached in a temporary file, because running
`docker compose config` per keystroke would make moving through the list as
slow as Compose is on a large project. The preview re-enters the script as
`dc --preview-service <name> <file>`, which also replaces the bat file preview
inherited from `FZF_DEFAULT_OPTS` — that one treats each service name as a
path and reports a missing file.

Esc, Ctrl+C, and Ctrl+Q abort either picker and cancel the whole command,
leaving exit status 130 and nothing run.

Both pickers require `fzf` and a terminal — without either, `dc` with no
arguments explains itself instead of guessing.

The script prefers the `docker compose` plugin and falls back to a standalone
`docker-compose` binary, exiting with an error when neither exists. Docker
itself is not installed by this module; the `docker` module does that on the
machines that need it, and `dc` works the same way against a Docker installed
by any other means.

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

`~/.config/zsh/85-p10k.zsh` is a single tracked file, stowed from this module, and it
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
- fzf defaults use fd for discovery and bat for previews, and its Ctrl+R,
  Ctrl+T, and Alt+C widgets come from the copy installed by the `must-have`
  dependency. The Alt+C preview prefers eza from the `fs` module and falls back
  to `ls`.
- the `y` function runs Yazi and changes the shell to Yazi's final directory.
- tmux, Docker, Git, filesystem, and media shortcuts, including the `dc`
  [Compose shortcut](#compose-shortcut), become useful when their corresponding
  modules are installed; unavailable commands are not installed by this module
  automatically.
- The [SSH host picker](#ssh-host-picker) lists hosts from `~/.ssh/config`;
  the `ssh` module's `config.local` and `config.d/*.conf` Includes are what
  make it show anything beyond the tracked config's catch-all `Host *`.

The `askPi` helper sends the current working directory, up to ten recent shell
commands, and the supplied question to the external `pi` command, then renders
its response with bat. Review shell history for secrets before invoking it.

The probe checks only that Zsh is available. Plugin, completion, and
cross-module command availability do not affect `./install --status`.
