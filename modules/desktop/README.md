# Desktop

macOS-specific command-line utilities, desktop applications, terminal
emulators, and window-management automation.

- Platforms: macOS
- Default: on
- Dependencies: `must-have`, `git`, `media`, `fs`

## Terminal and automation

| Utility | Purpose |
| --- | --- |
| [Hammerspoon](https://www.hammerspoon.org/) | Automates window management and input sources through Lua. |
| [WezTerm](https://wezterm.org/) | GPU-accelerated terminal emulator and multiplexer configured in Lua. |
| [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU-accelerated terminal emulator with keyboard-driven tabs, splits, and hints. |

These three applications are installed by `setup.sh` through Homebrew casks
when they are not already available.

## Homebrew manifests

The formula manifest installs:

| Formula | Purpose |
| --- | --- |
| `fetch` | Displays compact system information. |
| `openssl@3`, `gnupg`, `pkgconf` | Supplies cryptographic and build metadata tools used by desktop workflows. |
| `dockutil`, `duti`, `mas` | Manages the Dock, default applications, and Mac App Store applications. |
| `create-dmg` | Builds distributable macOS disk images. |

The cask manifest installs these application groups:

- inspection and automation: Apparency, KeyCastr, Raycast, and Suspicious
  Package
- connectivity: Tunnelblick, Pritunl, Wireshark, and Wireshark App
- Quick Look extensions: QLColorCode, QLMarkdown, QLStephen, QuickLook Video,
  QuickLookASE, and WebPQuickLook
- development and productivity: Bruno, LibreOffice, and pgAdmin 4
- desktop media: qBittorrent and Spotify

## Configuration

| Target | Behavior |
| --- | --- |
| `~/.hammerspoon/init.lua` | Configures window-management hotkeys and input-source automation. |
| `~/.config/wezterm/wezterm.lua` | Configures appearance, window sizing, tabs, panes, key bindings, and scrollback search. |
| `~/.config/kitty/kitty.conf` | Loads the themed, font, window, tab, and keyboard fragments from `conf.d/`. |
| `~/.config/kitty/scripts/toggle-split.sh` | Creates a vertical split when a tab has one pane, otherwise focuses the recent pane. |

The Kitty and WezTerm keymaps include macOS shortcuts and Cyrillic-layout
counterparts. The Kitty split helper uses remote control through
`unix:/tmp/kitty` and prefers `jq`, falling back to Python for JSON parsing.

The installation probe requires the core formulae plus Hammerspoon, WezTerm,
and Kitty. Optional cask applications are not part of the probe.
