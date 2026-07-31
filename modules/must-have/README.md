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
| `~/.config/micro/settings.json` | Configures Micro's theme, indentation, clipboard, search, wrapping, and editor UI. |
| `~/.config/direnv/direnv.toml` | Raises direnv's slow-`.envrc` warning to 20 seconds and stops it from printing the changed variables on every directory switch. |

`setup.sh` installs the Micro plugins `fzf`, `filemanager`, `editorconfig`,
`palettero`, `monokai-dark`, and `gotham-colors`. A failed plugin installation
is reported as a warning and does not fail the module.

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
