# Must-have

Baseline command-line tools and shared configuration expected by the other
modules on macOS and Debian/Ubuntu Linux.

- Platforms: macOS and Linux
- Default: on
- Dependencies: none

## Included tools

| Utility | Purpose |
| --- | --- |
| [Wget](https://www.gnu.org/software/wget/) | Downloads files over HTTP, HTTPS, and FTP, including recursive mirrors. |
| [curl](https://curl.se/) | Transfers data over HTTP and many other protocols. |
| [ca-certificates](https://curl.se/docs/caextract.html) | Supplies trusted roots for TLS verification. |
| [GnuPG](https://gnupg.org/) | Signs, verifies, encrypts, and decrypts data. |
| [rsync](https://rsync.samba.org/) | Synchronizes files locally or over SSH with delta transfers. |
| [Mosh](https://mosh.org/) | Keeps remote shells usable across network changes and disconnects. |
| [htop](https://htop.dev/) and [btop](https://github.com/aristocratos/btop) | Monitor processes, system load, memory, disks, and networks. |
| [pv](https://www.ivarch.com/programs/pv.shtml) | Reports throughput and progress for data moving through a pipe. |
| [GNU Screen](https://www.gnu.org/software/screen/) | Keeps shell sessions running while detached. |
| [Micro](https://micro-editor.github.io/) | Provides a small terminal editor with familiar key bindings. |
| [GNU Make](https://www.gnu.org/software/make/) and [Just](https://just.systems/) | Run build targets and project task recipes. |
| [direnv](https://direnv.net/) | Loads and unloads per-directory environment variables. |
| [fzf](https://github.com/junegunn/fzf) | Interactively filters lists with fuzzy matching. |
| [tealdeer](https://github.com/tealdeer-rs/tealdeer) | Displays concise `tldr` command examples. |

## Configuration

| Target | Purpose |
| --- | --- |
| `~/.curlrc` | Follows redirects, requests compression, retries a transient failure three times, defaults a schemeless URL to HTTPS, disables URL globbing, sets an automatic redirect referer, and times a connection out after 60 seconds. |
| `~/.wgetrc` | Configures timestamping, bounded retries, timeouts, recursive behavior, and stable requested filenames. |
| `~/.editorconfig` | Provides fallback UTF-8, line-ending, whitespace, and indentation rules outside projects with their own EditorConfig. |
| `~/.hushlogin` | Suppresses the login banner in new shells. |
| `~/.config/micro/settings.json` | Configures Micro's theme, indentation, clipboard, search, wrapping, editor UI, and the per-filetype overrides described below. |
| `~/.config/micro/bindings.json` | Binds the file tree, fuzzy file open, replace prompt, and case conversion to Alt keys, and quit to a double Escape. |
| `~/.config/micro/init.lua` | Holds the `quitOnSecondEscape` function the Escape binding ends in. |
| `~/.config/micro/colorschemes/catppuccin-macchiato.micro` | The [Catppuccin](https://github.com/catppuccin/micro) Macchiato colorscheme `settings.json` selects. |
| `~/.config/direnv/direnv.toml` | Raises direnv's slow-`.envrc` warning to 20 seconds and stops it from printing the changed variables on every directory switch. |

`setup.sh` installs the Micro plugins `fzf`, `filemanager`, `editorconfig`,
`palettero`, `manipulator`, and `detectindent`. A failed plugin installation is
reported as a warning and does not fail the module.

`detectindent` reads the indentation out of the file being opened and sets
`tabsize` and `tabstospaces` from it. It covers what `editorconfig` cannot: that
plugin only acts where an `.editorconfig` exists somewhere above the file, and
the per-filetype defaults below are a guess for everything else.

It also removes `gotham-colors`, `monokai-dark`, and `snippets` when an earlier
run left them installed. Micro embeds both colorschemes in its own runtime since
2.0.14, so a plugin copy under `~/.config/micro/plug` only shadows the embedded
file with an unmaintained one, and the `snippets` repository is archived. The
step deletes the plugin directory rather than calling `micro -plugin remove`,
which resolves the name against the plugin channel before it does anything and
then exits successfully having removed nothing once the plugin has been dropped
from that channel — as all three have been. A directory holding no `repo.json`
is not one Micro installed, so it is left alone, and a machine that never had
these plugins is left untouched.

It then patches `filemanager`. Version 3.5.1, the newest the plugin channel
offers, resolves a click in its tree with `BufPane:GetMouseClickLocation`, a
method Micro dropped in 2.0, so a click reports `attempt to call a non-function
object` and opens nothing; `LocFromVisual` replaces it. The patch is reapplied
after every install because it is overwritten each time, and skipped when the
old call is gone, so a fixed release ends it.

Every run reports `palettero is already installed but out-of-date`. The plugin
omits the `VERSION` declaration from its `main.lua`, so Micro reads the
installed version as `0.0.0-unknown` and compares that against the `0.0.5` in
the channel. The message is wrong, and updating will not clear it because the
release it downloads has the same omission.

The keys bound in `bindings.json` are Alt keys, because Micro's own defaults
already claim every useful Ctrl combination. `Alt-t` toggles the `filemanager`
tree, `Alt-o` opens a file through `fzf`, `Alt-r` opens the command bar with
`replace` prefilled, and `Alt-u` and `Alt-l` upper-case and lower-case the
selection through `manipulator`. On macOS these require the terminal to send
Option as Meta; the WezTerm configuration in the `desktop` module does.

`Enter` is bound to `lua:filemanager.try_open_at_cursor|InsertNewline`, so it
opens the entry under the cursor in the file tree and inserts a line break
everywhere else. The plugin itself only opens on `Tab` and a mouse click: its
tree is a read-only buffer, where `Enter` is suppressed. `try_open_at_cursor`
returns nothing outside the tree, which counts as failure and hands the press
on to `InsertNewline`.

Escape quits, but only when it is pressed twice within 750 ms: the first press
arms the exit and says so in the infobar, the second one runs `Quit`, which
still prompts for an unsaved buffer. The binding is the chain
`Deselect|RemoveAllMultiCursors|UnhighlightSearch|lua:initlua.quitOnSecondEscape`,
so a press that has a selection, extra cursors, or a search highlight to clear
does that instead and never reaches the exit. Two of Micro's own Escape actions
are deliberately left out of it: `Escape` always reports success and would end
the chain before anything else ran, and `ClearInfo` would consume the second
press by clearing the infobar hint the first one wrote. Escape keeps aborting
the command bar and the search prompt, which are a different pane with its own
keymap.

The colorscheme is Catppuccin Macchiato, stowed as a file under
`~/.config/micro/colorschemes/` rather than installed as a plugin. It needs
24-bit colour, which Micro emits only when `MICRO_TRUECOLOR` is set; the `zsh`
module exports it on a terminal that advertises true colour. Without it the
scheme still loads, quantized to the 256-colour palette.

`settings.json` carries per-filetype overrides for tab characters in Makefiles
and Go, two-space indentation in YAML, soft wrapping in Markdown and Git commit
messages, and trailing whitespace highlighting off for Markdown and patches.
They duplicate part of `~/.editorconfig` on purpose: the `editorconfig` plugin
walks up from the file being edited, so a file outside `$HOME` — a unit file, a
Makefile under `/opt`, a config in `/etc` — is reached by neither that file nor
any project one, and indentation would silently fall back to the four-space
default. Keep the two in step when either changes.

Both download configuration files apply to every curl or Wget invocation,
including installer scripts. They intentionally avoid settings that rename or
redirect downloaded files unexpectedly. Following redirects stays within that
rule because curl derives the local file name from the URL it was given and
nothing else, and `--remote-header-name`, which would let a server choose the
name, is not enabled. `--silent` and `--fail` are left out for a related reason:
both change what a caller sees instead of how the transfer happens, hiding error
messages and response bodies that scripts read.

`~/.editorconfig` sets two spaces for Lua and for shell scripts, matching the
Neovim, WezTerm, Hammerspoon, and installer sources in this repository rather
than the four-space default. StyLua reads EditorConfig, so the Lua value also
decides how it reformats. Patches keep their trailing whitespace, without which
they stop applying.

APT package availability differs across Debian and Ubuntu releases. The shared
installer skips packages with no candidate and reports a warning. The module
probe therefore treats `tldr` as optional on Linux, while Homebrew installations
must provide it.

direnv does nothing until a shell hook calls it on every prompt. The `zsh`
module evaluates `direnv hook zsh` when the binary is present, so installing
both modules is what makes `.envrc` files load automatically; for any other
shell the hook belongs in a machine-local rc file. An `.envrc` also stays
inactive until `direnv allow` is run in its directory, which is deliberate — the
file is shell code that would otherwise execute on `cd` into a cloned
repository. `hide_env_diff` in `direnv.toml` needs direnv 2.34 or later and is
ignored by older builds, which parse the file without failing on unknown keys.

Both direnv and the `mise` module manage the environment on directory changes,
and mise upstream does not support the combination. They stay out of each
other's way when direnv is limited to plain variables and `PATH` is left to
mise; the `mise` module's README describes the split.

The `fs` module depends on `must-have` for fzf.
