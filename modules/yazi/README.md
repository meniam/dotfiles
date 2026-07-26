# Yazi

Installs [Yazi](https://yazi-rs.github.io/), a terminal file manager, and restores its locked plugins and flavors with the bundled `ya` package manager.

| Utility | Purpose |
| --- | --- |
| [Yazi](https://yazi-rs.github.io/) | Navigates and manages files in a terminal user interface. |
| [UnZip](https://infozip.sourceforge.net/UnZip.html) | Extracts ZIP archives required by the Linux Yazi installer. |
| [7-Zip](https://www.7-zip.org/) | Creates and extracts 7z and other archive formats for file previews. |
| [jq](https://jqlang.org/) | Queries and transforms JSON data used by Yazi extensions. |
| [fd](https://github.com/sharkdp/fd) | Finds files quickly for Yazi search workflows. |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Searches file contents quickly for Yazi search workflows. |
| [fzf](https://github.com/junegunn/fzf) | Provides interactive fuzzy filtering for Yazi workflows. |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Learns frequently used directories for fast navigation. |

The module depends on `media` for media previews; its configuration is linked to `~/.config/yazi`.
