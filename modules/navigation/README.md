# Navigation

Provides terminal tools for finding, inspecting, filtering, and working with files; Midnight Commander remains in the separate `mc` module.

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

`fasd` is installed from APT only because it is not included in the Homebrew manifest; macOS provides `file` as a system utility.
