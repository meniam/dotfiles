# Eugene Myazin's Dotfiles

A modular dotfiles repository for macOS and Debian/Ubuntu Linux.

The repository provides an installation layer and opt-in configuration modules.
Machine-specific values and secrets are intentionally excluded.

## Features

- Selective installation of modules and their dependencies
- Interactive module picker for terminal sessions
- Profiles for machine roles such as `desktop` or `linux`
- Per-module manifests for Homebrew formulae, macOS casks, and APT packages
- GNU Stow linking of selected configuration files into `$HOME`
- Module status checks through optional installation probes
- Conflict backups before Stow replaces a regular file

## Requirements

- macOS with [Homebrew](https://brew.sh), or Debian/Ubuntu Linux with `apt-get`
- Bash 3.2 or later
- `sudo` access on Linux when system packages must be installed

GNU Stow is installed automatically when a selected module needs it.

## Commands

```bash
./install --list
./install --select
./install fs git
./install desktop multiplexer
./install --profile desktop
./install --status
```

| Command                      | Description                                                                |
| ---------------------------- | -------------------------------------------------------------------------- |
| `./install`                  | Opens the module picker in a terminal; on macOS, all macOS modules are preselected. Without a TTY, installs default modules. |
| `./install <module>...`      | Installs only the named modules and their dependencies.                    |
| `./install --profile <name>` | Installs all modules listed in a profile.                                  |
| `./install --select`         | Resolves and prints a selection without installing anything.               |
| `./install --list`           | Lists available modules, platforms, and descriptions.                      |
| `./install --status`         | Runs each module's optional installation probe.                            |

## Available modules

| Module       | Purpose                                         | Notes                                                                                                          |
| ------------ | ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `git`        | Git and GitHub command-line tooling             | Installs Git, GitHub CLI, Git LFS, and the Lazygit terminal UI.                                                 |
| `fs`         | Terminal navigation and file workflow           | Search, filtering, file inspection, Markdown viewing, archive tools, and disk usage analysis, plus the Yazi and Midnight Commander file managers; depends on `media`. |
| `media`      | Media inspection, conversion, and preview tools | Installs FFmpeg, ImageMagick, MediaInfo, ExifTool, Poppler, and Chafa.                                         |
| `multiplexer` | Terminal multiplexer tools                     | Installs tmux with TPM-managed plugins, and the herdr agent multiplexer.                                       |
| `lazydocker` | Terminal interface for Docker                   | Includes an empty upstream configuration file; Linux uses the project's upstream installer.                    |
| `must-have`  | Cross-platform baseline tools                   | Installs the common command-line baseline for macOS and Linux.                                                  |
| `desktop`    | macOS desktop software                          | Default macOS module; installs macOS-specific formulae and casks, plus Hammerspoon, WezTerm, Kitty, and all other macOS-compatible modules. |
| `linux`      | Debian/Ubuntu system prerequisites               | Installs Linux-specific command-line tools and build prerequisites.                                              |

## Adding a module

Create a directory at `modules/<name>/` with a `module.conf` file:

```bash
description="Zsh and shell plugins"
platforms="mac linux"
deps=""
default="on"
probe="command -v zsh"
```

The installer supports the following optional files:

```text
modules/<name>/
├── module.conf       # Metadata: description, platforms, dependencies, probe
├── packages.apt      # One Debian/Ubuntu package per line
├── packages.brew     # One Homebrew package per line
├── casks.brew        # One macOS Homebrew cask per line
├── setup.sh          # Module-specific setup after Stow linking
└── config/           # Files mirrored into $HOME by GNU Stow
```

`setup.sh` receives `OS`, `DOTFILES_DIR`, and `MODULE_DIR` in its environment.
It should be executable and idempotent.

Only `config/` is passed to Stow. Mirror the target path under `$HOME`:

```text
modules/zsh/config/.zshrc             -> ~/.zshrc
modules/nvim/config/.config/nvim       -> ~/.config/nvim
```

If a regular file conflicts with a Stow link, the installer moves it to a
timestamped directory under `~/.dotfiles-backups/`. Existing symbolic links
are left untouched and reported by Stow as conflicts.

## Profiles

Included profiles:

| Profile | Purpose |
| ------- | ------- |
| `desktop` | Installs every module supported on macOS; the Linux-only module is excluded. |
| `linux` | Installs the Debian server baseline. |

Create `profiles/<name>` with one module name per line:

```text
zsh
nvim
git
```

Then install it with:

```bash
./install --profile <name>
```

## Repository structure

```text
.
├── install            # Installer entry point
├── lib/
│   ├── common.sh       # OS, package manager, backup, and Stow helpers
│   ├── modules.sh      # Manifests, dependencies, profiles, and probes
│   └── picker.sh       # Interactive selector
├── modules/            # Installable tools and their configurations
└── profiles/           # Optional machine profiles
```

## Security

Never commit or deploy sensitive information. Review all changed files before
each commit or deployment for tokens, credentials, API keys, access details,
personal names, email addresses, private URLs, hostnames, and other personal
or account data. Keep machine-specific values and secrets in untracked local
files instead.

## Development

Validate shell changes before committing:

```bash
bash -n install lib/*.sh
shellcheck --shell=bash install lib/*.sh
```
