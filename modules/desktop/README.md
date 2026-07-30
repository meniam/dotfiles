# Desktop

macOS-specific command-line tools and desktop software, plus GPU-accelerated terminal emulators and window-management automation.

| Utility | Purpose |
| --- | --- |
| [Hammerspoon](https://www.hammerspoon.org/) | Automates window management and input sources via Lua. |
| [WezTerm](https://wezterm.org/) | GPU-accelerated terminal emulator and multiplexer configured in Lua. |
| [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU-accelerated terminal emulator with keyboard-driven window and tab management. |

Hammerspoon links `~/.hammerspoon/init.lua`. WezTerm links its Lua configuration; on macOS it uses the Homebrew cask, while Linux uses an already configured APT source. Kitty links its custom configuration, including the split-toggle script in `config/.config/kitty/scripts/`; on macOS it uses the Homebrew cask, while Linux uses an already configured APT source.
