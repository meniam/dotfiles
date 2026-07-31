# FS

Provides terminal tools for finding, inspecting, filtering, and working with files, including the Yazi and Midnight Commander file managers, common archive utilities, and disk usage analysis.

| Utility | Purpose |
| --- | --- |
| [Eza](https://eza.rocks/) | Lists files and directories with modern, Git-aware output. |
| [fd](https://github.com/sharkdp/fd) | Finds files and directories with a fast, simple command-line interface. |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Searches file contents recursively with fast regular-expression matching. |
| [fzf](https://github.com/junegunn/fzf) | Interactively filters lists with fuzzy matching. |
| [peco](https://github.com/peco/peco) | Interactively filters text streams in the terminal. |
| [fasd](https://github.com/clvv/fasd) | Tracks frequently used files and directories for fast shell navigation. |
| [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree) | Displays directory hierarchies as a tree. |
| [file](https://darwinsys.com/file/) | Identifies file types from their contents. |
| [bat](https://github.com/sharkdp/bat) | Displays file contents with syntax highlighting and Git integration. |
| [GNU Stow](https://www.gnu.org/software/stow/) | Manages sets of symbolic links, including dotfiles. |
| [entr](https://eradman.com/entrproject/) | Runs a command when watched files change. |
| [Glow](https://github.com/charmbracelet/glow) | Renders Markdown files in the terminal. |
| [Yazi](https://yazi-rs.github.io/) | Navigates and manages files in a terminal user interface. |
| [UnZip](https://infozip.sourceforge.net/UnZip.html) | Extracts ZIP archives required by the Linux Yazi installer. |
| [7-Zip](https://www.7-zip.org/) | Creates and extracts 7z and other archive formats for file previews. |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Learns frequently used directories for fast navigation. |
| [Midnight Commander](https://midnight-commander.org/) | Dual-pane terminal file manager for navigating, viewing, and manipulating files. |
| [Zip](https://infozip.sourceforge.net/Zip.html) | Creates ZIP archives from files and directories. |
| [Zstandard](https://facebook.github.io/zstd/) | Compresses and decompresses data with the Zstandard algorithm. |
| [Ouch](https://github.com/ouch-org/ouch) | Creates, extracts, and lists many archive formats through a unified command-line interface. |
| [bzip2](https://sourceware.org/bzip2/) | Compresses and decompresses data with the bzip2 algorithm. |
| [GNU Tar](https://www.gnu.org/software/tar/) | Creates and extracts tar archives and their compressed variants. |
| [RAR](https://www.rarlab.com/) | Creates proprietary RAR archives for compression and backup workflows. |
| [UnRAR](https://www.rarlab.com/rar_add.htm) | Extracts and tests proprietary RAR archives. |
| [Ncdu](https://dev.yorhel.nl/ncdu) | Browses directory sizes interactively in a terminal interface. |
| [Dust](https://github.com/bootandy/dust) | Shows disk usage with a compact, visual directory summary. |
| [Duf](https://github.com/muesli/duf) | Displays disk free space in a readable table. |
| [Pydf](https://github.com/k4rtik/pydf) | Displays filesystem free space with colourized output. |

`bat` reads `~/.config/bat/config`, which selects the terminal-palette `ansi` theme for the same reason the Git module does, and maps the file names this repository uses (`*.conf` Git includes, `module.conf`, `packages.*`, `justfile`) onto the right syntaxes. Because bat derives the syntax from the file name, piped input arrives unhighlighted: pass `bat -l md` or `bat --file-name=answer.md`.

`fasd` is installed from APT only because it is not included in the Homebrew manifest; macOS provides `file` as a system utility. `pydf` is installed from APT only because it is not included in the Homebrew manifest. The module depends on `media` for Yazi previews; Yazi's locked plugins and flavors are restored by `setup.sh`. On Linux, `setup.sh` uses a configured APT package for Ouch when available or the project's official static release otherwise. RAR and UnRAR are proprietary utilities: the Linux setup uses them only when the configured APT sources provide the packages, which may require enabling a non-free or multiverse repository.
