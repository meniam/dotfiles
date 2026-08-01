# Homebrew

Homebrew itself: the package manager every other macOS module installs through,
plus a Brewfile snapshot helper for reproducing a machine's package set.

- Platforms: macOS
- Default: on
- Dependencies: none

## Bootstrap

Homebrew is a prerequisite of the whole macOS installation, not of this module
alone, so `lib/common.sh` installs it in `ensure_base_tools()` before the first
module runs. `ensure_homebrew()` there:

1. Returns immediately when `brew` is already on `PATH`.
2. Evaluates `brew shellenv` when the prefix exists but is not on `PATH`, which
   is the state right after an installation in a non-login shell.
3. Otherwise downloads the upstream installer to a temporary file, checks that
   it is the expected script, and runs it with `NONINTERACTIVE=1`.

The prefix is `/opt/homebrew` on Apple silicon and `/usr/local` on Intel, or
`HOMEBREW_PREFIX` when it is already set. The upstream installer calls `sudo`
itself for the prefix it creates and installs the Command Line Tools when they
are missing, so the first run on a clean machine can ask for a password and take
several minutes.

Because the bootstrap lives in the shared installer, other macOS modules do not
declare a dependency on this module; selecting `nvim` alone still gets a working
`brew`. Selecting this module adds the snapshot helper and the metadata refresh.

## Setup side effects

`setup.sh` runs `ensure_homebrew()`, creates
`~/.config/homebrew/`, verifies that the installed Homebrew has the built-in
`brew bundle` command, and runs `brew update` under a 300-second timeout. A
failed `brew update` is a warning: the module continues with the cached formula
metadata. Installed packages are never upgraded automatically; run
`brew upgrade` when you want that.

## Configuration

| Target | Purpose |
| --- | --- |
| `~/.local/bin/brew-snapshot` | Writes, checks, and replays a Brewfile snapshot of the installed formulae, casks, and taps. |

`~/.config/homebrew/Brewfile` is machine-local state and is deliberately not
tracked in this repository: it describes one machine at one point in time, while
`packages.brew` and `casks.brew` in each module describe the intended set.

| Command | Effect |
| --- | --- |
| `brew-snapshot dump` | Overwrites the Brewfile with `brew bundle dump --force --describe`. |
| `brew-snapshot restore` | Runs `brew bundle install` for the Brewfile. |
| `brew-snapshot check` | Reports which Brewfile entries are missing. |
| `brew-snapshot list` | Prints the Brewfile. |
| `brew-snapshot path` | Prints the Brewfile path. |

Set `HOMEBREW_BUNDLE_FILE` to use a different path, for example to keep one
snapshot per machine in a synced directory.

There is no `brew-snapshot` command for `brew bundle cleanup`. That subcommand
uninstalls everything absent from the Brewfile, which on a snapshot taken before
a module was installed removes packages this repository just put there. Run it
directly when that is what you want.

## Limitations

- macOS only. Homebrew on Linux is not used by this repository; the Linux
  modules install from APT and `install_packages_for()` does not read
  `packages.brew` there.
- The bootstrap needs network access, and on a clean machine also `sudo` and the
  Command Line Tools.
- `brew bundle dump` records what is installed, including packages installed by
  hand and by other modules. It is a backup, not a manifest to install from on a
  new machine without reading it first.
