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
| `~/.curlrc` | Enables automatic redirect referers and a 60-second connection timeout. |
| `~/.wgetrc` | Configures timestamping, bounded retries, timeouts, recursive behavior, and stable requested filenames. |
| `~/.editorconfig` | Provides fallback UTF-8, line-ending, whitespace, and indentation rules outside projects with their own EditorConfig. |
| `~/.hushlogin` | Suppresses the login banner in new shells. |
| `~/.config/micro/settings.json` | Configures Micro's theme, indentation, clipboard, search, wrapping, and editor UI. |

`setup.sh` installs the Micro plugins `fzf`, `filemanager`, `editorconfig`,
`palettero`, `monokai-dark`, and `gotham-colors`. A failed plugin installation
is reported as a warning and does not fail the module.

Both download configuration files apply to every curl or Wget invocation,
including installer scripts. They intentionally avoid settings that rename or
redirect downloaded files unexpectedly.

APT package availability differs across Debian and Ubuntu releases. The shared
installer skips packages with no candidate and reports a warning. The module
probe therefore treats `tldr` as optional on Linux, while Homebrew installations
must provide it.

The module installs `direnv` but does not add a shell hook. Enable the hook in a
machine-local shell override when automatic `.envrc` loading is desired.
The `fs` module depends on `must-have` for fzf.
