# FS

Terminal tools for finding, inspecting, filtering, previewing, archiving, and
managing files and disk space.

- Platforms: macOS and Linux
- Default: off
- Dependencies: `media`, `must-have`

## Included tools

| Utility | Purpose |
| --- | --- |
| [Eza](https://eza.rocks/) | Lists files with Git metadata, icons, and a custom colour theme. |
| [fd](https://github.com/sharkdp/fd) | Finds files and directories with a concise command-line interface. |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Searches file contents recursively. |
| [fzf](https://github.com/junegunn/fzf) | Interactively filters lists; supplied by the `must-have` dependency. |
| [peco](https://github.com/peco/peco) | Interactively filters text streams. |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Learns frequently used directories and powers Yazi's jump keymap. |
| [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree) | Displays directory hierarchies. |
| [file](https://darwinsys.com/file/) | Identifies file types from their contents. |
| [bat](https://github.com/sharkdp/bat) | Displays files with syntax highlighting and Git integration. |
| [GNU Stow](https://www.gnu.org/software/stow/) | Manages sets of symbolic links, including this repository's payloads. |
| [entr](https://eradman.com/entrproject/) | Runs a command when watched files change. |
| [Glow](https://github.com/charmbracelet/glow) | Renders Markdown in the terminal. |
| [jq](https://jqlang.github.io/jq/) | Queries and transforms JSON. |
| [yq](https://github.com/mikefarah/yq) | Queries and transforms YAML and related formats. |
| [GNU Parallel](https://www.gnu.org/software/parallel/) | Runs jobs concurrently from command-line input. |
| [hyperfine](https://github.com/sharkdp/hyperfine) | Benchmarks commands with warmups and statistics. |
| [watchexec](https://github.com/watchexec/watchexec) | Reruns a command on file changes, killing the previous run. |
| [Miller](https://miller.readthedocs.io/) | Queries and reshapes CSV, TSV, and JSON records. |
| [sd](https://github.com/chmln/sd) | Replaces text with plain regex syntax instead of `sed s///`. |
| [choose](https://github.com/theryangeary/choose) | Selects fields from a line without an `awk` program. |
| [Yazi](https://yazi-rs.github.io/) | Navigates files with rich previews in a terminal UI. |
| [DuckDB](https://duckdb.org/), [hexyl](https://github.com/sharkdp/hexyl), [SQLite](https://sqlite.org/), [Typst](https://typst.app/), [DjVuLibre](https://djvu.sourceforge.net/), and [Transmission](https://transmissionbt.com/) | Back the Yazi previewers for tabular data, unknown binaries, databases, `.typ`, `.djvu`, and `.torrent` files. |
| [Midnight Commander](https://midnight-commander.org/) | Provides a dual-pane terminal file manager and editor. |
| Zip, UnZip, 7-Zip, Zstandard, bzip2, and tar | Creates and extracts common archive formats. |
| [Ouch](https://github.com/ouch-org/ouch) | Provides one interface for multiple archive formats. |
| RAR and UnRAR | Creates and extracts proprietary RAR archives when platform packages are available. |
| [Ncdu](https://dev.yorhel.nl/ncdu), [Dust](https://github.com/bootandy/dust), and [Duf](https://github.com/muesli/duf) | Inspects disk usage and free space. |
| [Pydf](https://github.com/k4rtik/pydf) | Displays colourized filesystem usage on Linux. |

## Configuration

| Target | Purpose |
| --- | --- |
| `~/.config/bat/config` | Uses the terminal-aware `ansi` theme, enables structured output, and maps repository-specific filenames to syntaxes. |
| `~/.config/eza/theme.yml` | Defines file-kind, permission, Git, filename, and extension colours. |
| `~/.config/ripgrep/ripgreprc` | Enables smart case, hidden-file search, `.git` exclusion, long-line previews, automatic PCRE2 fallback, and the `pkgs` type. |
| `~/.config/yazi/` | Configures layout, openers, keymaps, previewers, themes, and locked plugins and flavours, and vendors one plugin under `plugins/`. |
| `~/.config/mc/ini` | Configures Midnight Commander. |
| `~/.pydfrc` | Configures Pydf's columns, colours, and filesystem display. |

`bat` chooses syntax from a filename, so piped input may need an explicit
language such as `bat -l md` or a synthetic filename such as
`bat --file-name=answer.md`.

ripgrep has no default configuration path. The `zsh` module exports
`RIPGREP_CONFIG_PATH` only when the stowed file exists; without that environment
variable the file remains inert. Its settings affect ripgrep calls made by
fzf, Yazi, Neovim, and other programs, so output-shaping options such as
`--heading`, `--pretty`, and `--json` do not belong in the shared file.

## Platform and setup notes

- macOS uses Homebrew for Yazi, Ouch, and the archive tools. The operating
  system already supplies `file`, Zip, and UnZip.
- Linux downloads the current official Yazi release for x86_64 or arm64 into
  `~/.local/bin` when a working Yazi is not already present.
- `setup.sh` restores the revisions locked in Yazi's `package.toml` with
  `ya pkg install`.
- Linux installs Ouch from APT when available and otherwise downloads its
  official static release for x86_64 or arm64.
- RAR and UnRAR may require a non-free repository on Linux. Their absence is a
  warning during setup and does not hold the probe back, since neither command
  can be installed everywhere.
- `setup.sh` creates `~/.parallel/will-cite`. Without it GNU Parallel prints its
  citation request into the stderr of every script that calls it.
- Homebrew installs GNU tar as `gtar`, because `tar` on macOS is a system
  utility; the probe checks for `gtar` there and for `tar` on Linux.
- `.pydfrc` configures an APT-only tool. Stow links the whole payload on both
  platforms, so `setup.sh` removes the dangling macOS link afterwards.
- `duckdb`, `typst`, `watchexec`, `sd`, and `choose` are absent from older
  Debian and Ubuntu releases. The installer skips a package without an APT
  candidate and warns, and the probe requires those five on macOS only.
- The `media` dependency supplies FFmpeg, ImageMagick, MediaInfo, Poppler, and
  Chafa for Yazi previews. The `must-have` dependency supplies fzf.

### Yazi plugins

`ya pkg install` restores every revision locked in `package.toml`. Two plugins
sit outside that mechanism:

- `vscode-git-gutter`, the previewer for `text/*`, has no public upstream to
  fetch from, so its source is vendored in
  `config/.config/yazi/plugins/vscode-git-gutter.yazi` and Stow links it like
  any other payload. It needs `bat` and `git`, both of which the module and its
  dependencies already install.
- `miller` is not locked at all: its upstream still ships the pre-0.3 `init.lua`
  layout that `ya pkg` cannot deploy. The `mlr` binary is installed and works on
  its own.

Several locked plugins shell out to binaries this module now installs. Two more
come from `media` and are single-platform by design: `office` needs LibreOffice,
which is a macOS cask, and `preview-epub` needs `gnome-epub-thumbnailer`, which
is packaged for Debian and Ubuntu only. On the platform without it the file
falls through to the hex previewer.
