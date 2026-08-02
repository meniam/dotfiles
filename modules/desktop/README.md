# Desktop

macOS-specific command-line utilities, desktop applications, terminal
emulators, window-management automation, system defaults, and default
application handlers.

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
| `duti` | Sets default application handlers; `setup.sh` applies the payload below. |
| `dockutil`, `mas` | Manages the Dock and Mac App Store applications from the command line. Installed for manual use; `setup.sh` calls neither. |
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
| `~/.config/duti/settings.duti` | Assigns default applications for source, configuration, and plain-text types. |
| `~/.config/launchservices/handlers.conf` | Assigns default applications for extensions that have no type of their own. |

The Kitty and WezTerm keymaps include macOS shortcuts and Cyrillic-layout
counterparts. The Kitty split helper uses remote control through
`unix:/tmp/kitty` and prefers `jq`, falling back to Python for JSON parsing.

Cmd+Shift and Ctrl+Shift with the arrow keys send the Shift+Home and Shift+End
sequences `\x1b[1;2H` and `\x1b[1;2F`. They used to send `\x1b[97;6u` and
`\x1b[101;6u`, the CSI-u encoding of Shift+Ctrl+A and Shift+Ctrl+E, which
`zsh-shift-select` binds explicitly; that made the shortcut work on the command
line only. CSI-u belongs to the Kitty keyboard protocol, and tcell does not
decode it, so terminal applications built on tcell — micro among them — saw
nothing at all. `zsh-shift-select` binds Shift+Home and Shift+End as well, so
the command line keeps the behavior it had.

## System defaults

macOS preferences belong to `cfprefsd`, which owns the plists under
`~/Library/Preferences` and replaces a symlink placed there with a real file.
They cannot be a stowed payload like everything else in this repository, so
`setup.sh` writes them with `defaults` instead. Each value is read first: a
repeated run rewrites nothing, restarts nothing, and reports no changes.

| Setting | Effect |
| --- | --- |
| Five `NSAutomatic*` substitutions off | Straight quotes stay straight, `--flag` stays a double hyphen, and no autocorrection or sentence capitalisation happens in Cocoa text fields. |
| `ApplePressAndHoldEnabled false` | A held key repeats instead of opening the accent picker. Accented Latin characters come from the Character Viewer; Cyrillic input is unaffected. |
| `AppleShowAllExtensions true` | Finder shows every file extension. |
| `AppleKeyboardUIMode 3` | Tab moves between all controls in a dialog, not only text fields. |
| `NSNavPanelExpandedStateForSaveMode true` | Save panels open with the full folder tree. |
| `NSDocumentSaveNewDocumentsToCloud false` | New documents default to the local disk instead of iCloud. |
| Finder `_FXShowPosixPathInTitle`, `ShowStatusBar`, `_FXSortFoldersFirst` | Full POSIX path in the title, item count and free space at the bottom, folders before files. |
| Finder `FXDefaultSearchScope SCcf` | Search starts in the current folder rather than the whole Mac. |
| Finder `FXEnableExtensionChangeWarning false` | Renaming across extensions stops prompting. |
| `DSDontWriteNetworkStores`, `DSDontWriteUSBStores` | No `.DS_Store` on network shares or USB volumes. Applies to volumes mounted after the change. |
| `screencapture location`, `disable-shadow` | Screenshots collect in `~/Screenshots`, without the translucent window shadow. |
| Dock `autohide`, `autohide-delay 0`, `autohide-time-modifier 0.2` | The Dock hides and comes back immediately instead of after half a second. |
| Dock `show-recents false`, `mru-spaces false` | Recent applications do not stretch the Dock, and Spaces keep a fixed order. |
| Trackpad `Clicking`, `com.apple.mouse.tapBehavior` | Tap to click, for the built-in trackpad and for a Magic Trackpad over Bluetooth. `tapBehavior` is written both per-host, which is what the driver reads, and globally, which is what System Settings displays. The built-in trackpad applies it at the next login. |

Finder, the Dock, and SystemUIServer are restarted only when a value in their
own domain actually changed; macOS relaunches all three. Settings in
`NSGlobalDomain` reach each application the next time it starts.

### Reviewing and undoing

`DOTFILES_DRY_RUN=1` reports every pending change and writes nothing:

```bash
DOTFILES_DRY_RUN=1 DOTFILES_DIR="$PWD" bash modules/desktop/setup.sh
```

Before the first value in a domain is modified, that domain is exported to
`~/.dotfiles-backups/<timestamp>-<pid>/defaults/<domain>.plist`. Importing the
dump is the only faithful undo, because `defaults delete` restores Apple's
default rather than the value that was there before:

```bash
defaults import com.apple.finder ~/.dotfiles-backups/<timestamp>-<pid>/defaults/com.apple.finder.plist
killall Finder
```

Per-host values written with `-currentHost` live in a separate store and are not
part of the dump.

## Default application handlers

`setup.sh` applies `~/.config/duti/settings.duti` with `duti`. Reapplying a
binding that is already in place does nothing, so the file is applied on every
run.

LaunchServices binds a handler to a type identifier rather than to an extension.
duti resolves an extension to its UTI first, which makes `.py` and
`public.python-script` the same instruction, and means one identifier can carry
several extensions: `public.php-script` covers `.php`, `.php3`, `.php4`, and
`.phtml`. Assignments also propagate asynchronously — `duti -x <ext>` can report
the previous application for a few seconds after a successful write.

Visual Studio Code takes plain text, the source-code and script parents, the
shell, Bash, Zsh, Python, Ruby, and PHP script types, Lua, Rust, Go, C sources
and headers, JavaScript, CSS, YAML, TOML, INI, SQL, XML, patch files, `.conf` by
extension, and `public.mpeg-2-transport-stream`. That last one is `.ts`: the type
is correct for the container format and cannot be told apart from TypeScript, so
downloaded transport streams open in the editor as well. Switching editors means
replacing the bundle ID on those lines.

Three handlers are pinned rather than left implicit, so that installing or
updating other software cannot take the type over: Google Chrome for
`public.html`, Typora for Markdown, and PowerJSON Editor for JSON. HTML staying
with the browser also means `*.twig.html` opens in Chrome, because only the last
extension of a file name is ever considered.

### Extensions without a type

`.jsx`, `.tsx`, `.sass`, `.scss`, `.twig`, `.env`, and `.local` cannot be
assigned through duti at all: no application declares a real type for them, so
macOS generates an identifier from the extension, and LaunchServices refuses a
handler for a generated one with `error -50`. The application that opens them
today claims the extension in its own `Info.plist`, which no type-level
assignment displaces.

Finder's `Change All…` solves this by writing a different kind of record — one
keyed by the extension rather than by a type — into
`~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist`.
`setup.sh` writes the same record for every line of
`~/.config/launchservices/handlers.conf`, then signals `lsd` to reread its table,
without which the change appears to have had no effect.

Two properties follow from storing preferences macOS owns. A major system upgrade
may reset them, and an extension already bound to a different application is
reported and left alone rather than overwritten, so a choice made in Finder is
never silently reverted — remove the entry there to let the payload take over.
`*.twig.html` stays out of reach either way, because only the last extension of a
file name is ever considered and `html` belongs to the browser. Binding `local`
for `.env.local` reaches every other `*.local` file too, `~/.ssh/config.local`
included.

The block needs `jq` to recognise an existing record; it comes from the `fs`
module this one depends on, and without it the payload is skipped rather than
applied blindly.

## Dock contents

The composition of the Dock is deliberately not automated. A tracked list would
publish the installed application inventory, and applying it declaratively means
removing anything added by hand on every install — including on a `default="on"`
module that runs during every `./install`. `dockutil` is installed for manual
use.

## Installation probe

The probe requires the formulae, `dockutil`, `duti`, `mas`, Hammerspoon,
WezTerm, Kitty, and the stowed `duti` payload. Optional cask applications are
not part of it, and neither are the values written with `defaults`: changing one
of them in System Settings afterwards is legitimate and must not make
`./install --status` report the module as missing.
