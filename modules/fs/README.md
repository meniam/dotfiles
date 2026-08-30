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
| [bat](https://github.com/sharkdp/bat) | Displays files with syntax highlighting and Git integration. The bundled Catppuccin themes arrived in 0.26.0, so on Linux `setup.sh` replaces an older APT build with the release binary. |
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
| [rich-cli](https://github.com/Textualize/rich-cli) | Renders JSON and reStructuredText for the Yazi previewer, and formats files, Markdown, and syntax on the command line. |
| [mermaid-ascii](https://github.com/AlexanderGrooff/mermaid-ascii) | Renders Mermaid diagrams as ASCII art for the Markdown previewer and for `glowm`. Neither Homebrew nor APT packages it, so `setup.sh` fetches the release binary into `~/.local/bin`. |
| [Midnight Commander](https://midnight-commander.org/) | Provides a dual-pane terminal file manager and editor. |
| Zip, UnZip, 7-Zip, Zstandard, bzip2, and tar | Creates and extracts common archive formats. |
| [Ouch](https://github.com/ouch-org/ouch) | Provides one interface for multiple archive formats. |
| RAR and UnRAR | Creates and extracts proprietary RAR archives when platform packages are available. |
| [Ncdu](https://dev.yorhel.nl/ncdu), [Dust](https://github.com/bootandy/dust), and [Duf](https://github.com/muesli/duf) | Inspects disk usage and free space. |
| [Pydf](https://github.com/k4rtik/pydf) | Displays colourized filesystem usage on Linux. |

## Configuration

| Target | Purpose |
| --- | --- |
| `~/.config/bat/config` | Uses the `Catppuccin Mocha` theme, enables structured output, and maps repository-specific filenames to syntaxes. |
| `~/.config/eza/theme.yml` | Defines file-kind, permission, Git, filename, and extension colours. |
| `~/.config/ripgrep/ripgreprc` | Enables smart case, hidden-file search, `.git` exclusion, long-line previews, automatic PCRE2 fallback, and the `pkgs` type. |
| `~/.config/yazi/` | Configures layout, openers, keymaps, previewers, themes, and locked plugins and flavours, and vendors two plugins under `plugins/`. |
| `~/.config/mc/ini` | Configures Midnight Commander. |
| `~/.config/glow/theme.json` | Glow's Markdown theme: upstream `dark` with the chroma `error` background dropped. |
| `~/.local/bin/glowm` | Renders Markdown with `glow`, drawing every ```` ```mermaid ```` fence as ASCII art. |
| `~/.pydfrc` | Configures Pydf's columns, colours, and filesystem display. |

`bat` chooses syntax from a filename, so piped input may need an explicit
language such as `bat -l md` or a synthetic filename such as
`bat --file-name=answer.md`.

`glow` has a configuration file — `~/Library/Preferences/glow/glow.yml` on macOS,
`~/.config/glow/glow.yml` on Linux, both created by `glow config` — but version
2.1.2 applies neither `style` nor `width` from it: the default of the matching
flag wins, and `GLOW_STYLE` and `GLAMOUR_STYLE` are ignored as well. The theme
therefore has to be passed per call, which the `zsh` module's `glow` alias does.
The `myazin-mermaid-glow` previewer passes its own `--style` and does not read
either file.

Upstream `dark` styles the chroma `error` token as white on `#F05B5B`. Chroma
guesses a lexer from the content of a fence that has no language, so anything it
then fails to tokenise — ASCII diagrams above all — comes out as solid salmon
blocks; the same ER diagram scores 196 painted spans under `dark` and none here.
The theme keeps the red as a foreground colour instead.

Backgrounds in this file behave less predictably than foregrounds, in two ways
worth knowing before editing them:

- Anything outside the `chroma` block — `code.background_color` among them — is
  written through termenv, which picks its palette from the terminal. In a real
  terminal that is the full 24-bit profile and a hex lands exactly. When stdout
  is a pipe and `CLICOLOR_FORCE` is what enables colour, which is precisely how
  the Yazi previewer runs `glow`, termenv drops to the 16 ANSI colours: `#1f252d`
  and `236` both arrive as plain black, and a slightly lighter `#2a313a` snaps to
  cyan. So an inline-code background is a terminal-only effect. ANSI has no alpha
  either, so an eight-digit `#rrggbbaa` is parsed as the six-digit colour and the
  terminal's own window transparency does not apply to an explicit background.
- Neither `code_block.background_color` nor the chroma `background` entry paints
  a code block: glamour 0.10.0 emits no background for it, so the `background`
  value here is inert and kept only to match upstream's shape. What does work is
  a `background_color` on the individual chroma token types — chroma writes its
  own 256-colour codes and they survive the previewer — but it paints behind the
  tokens rather than the block, leaving each line's trailing padding unfilled.

### glowm

`glowm` is the command-line counterpart of the `myazin-mermaid-glow` previewer
below, stowed into `~/.local/bin` and using the same pipeline: each
```` ```mermaid ```` fence becomes a marker word, and the art from
`mermaid-ascii` is spliced over that marker in glow's output. Handing the art to
glow instead would wrap a wide diagram onto the next row and paint the theme's
code-block background behind the box drawing.

```bash
glowm README.md          # a file
glowm -p README.md       # through $PAGER, which keeps the colour with less -R
glowm --ascii README.md  # plain ASCII instead of box drawing
cat README.md | glowm    # stdin
```

Unrecognised flags go to glow untouched, and `--style` defaults to the stowed
theme for the same reason the `zsh` alias sets it, since an alias does not reach
a script. It takes one file or stdin rather than glow's directories and URLs,
and `--pager` is handled here because glow would otherwise page its own output
before the diagrams are spliced in. Without `mermaid-ascii` it warns once and
leaves the fences as source; a diagram that fails to render keeps its source and
is prefixed with the reason.

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
- `duckdb`, `typst`, `watchexec`, `sd`, `choose`, and `rich-cli` are absent from
  older Debian and Ubuntu releases. The installer skips a package without an APT
  candidate and warns, and `setup.sh` then fills the gap on Linux: `duckdb`,
  `typst`, `watchexec`, `sd`, and `choose` come from their upstream x86_64 or
  arm64 release into `~/.local/bin`, and `rich-cli` is installed as a uv tool.
  Each fallback is best-effort and warns instead of failing the module.
- `watchexec` and `typst` publish their Linux builds as `.tar.xz` only, so the
  module installs `xz-utils`; `watchexec` and `sd` name the artifact after the
  release, so their tag is resolved through the `/releases/latest` redirect.
- The probe requires those five binaries on both platforms. `rich` is required
  on macOS and on any machine that has `uv`, since the Linux fallback needs the
  `python` module's uv; without uv the previewers degrade instead.
- The `media` dependency supplies FFmpeg, ImageMagick, MediaInfo, Poppler, and
  Chafa for Yazi previews. The `must-have` dependency supplies fzf.

### Yazi plugins

`ya pkg install` restores every revision locked in `package.toml`. Four plugins
sit outside that mechanism:

- `vscode-git-gutter`, the previewer for `text/*`, has no public upstream to
  fetch from, so its source is vendored in
  `config/.config/yazi/plugins/vscode-git-gutter.yazi` and Stow links it like
  any other payload. It needs `bat` and `git`, both of which the module and its
  dependencies already install.
- `myazin-mermaid-glow`, the previewer for `.md`, `.mmd`, and `.mermaid`, is
  written for this repository and vendored the same way. It swaps every
  ```` ```mermaid ```` fence for ASCII art from `mermaid-ascii` and pipes the
  document through `glow`, so diagrams need no image protocol and scroll with
  the surrounding prose. `glow` is required; `mermaid-ascii` is optional and
  the fences stay as source without it. Its own README documents the
  configuration and the cache.
- `myazin-fzf-flat`, bound to `\` and `ё`, is written for this repository and
  vendored the same way. It runs fzf over a single depth-capped `fd` listing of
  the current directory and reveals the pick, covering the case the built-in
  `fzf` jump on `Z` handles badly: a wanted entry that sits in the directory
  already on screen, under a large subtree. `|` and `Ё` pass a depth of 2 to the
  same plugin and so reach one level below it. It needs `fzf` and `fd`, and
  falls back to Debian's `fdfind` name.
- `miller` is not locked at all: its upstream still ships the pre-0.3 `init.lua`
  layout that `ya pkg` cannot deploy. The `mlr` binary is installed and works on
  its own.

`rich-preview` is locked like the rest and previews `.json` and `.rst` through
`rich-cli`. The other formats it supports keep their dedicated previewers:
Markdown goes to `myazin-mermaid-glow`, CSV and TSV to `duckdb`, and notebooks
to `nbpreview`. Where `rich` is missing — a release with no APT candidate and no
uv to install it with — the plugin falls back to Yazi's built-in code previewer,
so the setup degrades rather than breaks.

Several locked plugins shell out to binaries this module now installs. Two more
come from `media` and are single-platform by design: `office` needs LibreOffice,
which is a macOS cask, and `preview-epub` needs `gnome-epub-thumbnailer`, which
is packaged for Debian and Ubuntu only. On the platform without it the file
falls through to the hex previewer.
