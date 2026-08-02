# Dotfiles

A modular dotfiles repository for macOS and Debian/Ubuntu Linux. The installer
combines opt-in package modules, GNU Stow-managed configuration files, module
dependencies, and profiles for common machine roles.

Machine-specific values and secrets are intentionally excluded.

## Features

- Interactive or explicit module selection
- Dependency resolution with cycle and unknown-module checks
- Profiles for macOS, Linux, language toolchains, and container environments
- Homebrew bootstrap, formula, and cask manifests on macOS
- APT package manifests on Debian/Ubuntu Linux
- GNU Stow linking of module payloads into `$HOME`
- Conflict backups under `.backups/` in the repository
- Optional idempotent setup scripts and installation probes per module
- Read-only list, selection, and status commands

## Requirements

- macOS, or Debian/Ubuntu Linux with `apt-get`
- Bash 3.2 or later
- Network access for package managers and modules that download upstream
  releases
- `sudo` access on Linux when system packages or files must be installed

[Homebrew](https://brew.sh) on macOS and GNU Stow on both platforms are
installed automatically when they are not already available. The Homebrew
bootstrap runs the upstream installer, which needs `sudo` and installs the
Command Line Tools on a clean machine.

## Usage

Inspect the available modules and resolve a selection before installing:

```bash
./install --list
./install --select
```

Install named modules or a profile:

```bash
./install git fs
./install --profile mac
./install --profile linux
```

Inspect module probes or show detailed installation progress:

```bash
./install --status
./install --verbose git
```

| Command | Description |
| --- | --- |
| `./install` | Opens the picker with default modules preselected. Without a TTY, installs the defaults. |
| `./install <module>...` | Installs the named modules and their dependencies. |
| `./install --profile <name>` | Installs the modules listed in a profile and their dependencies. |
| `./install --select` | Opens the picker and prints the resolved selection without installing. Without a TTY, prints the resolved defaults. |
| `./install --profile <name> --select` | Preselects a profile and prints the resolved selection without installing. |
| `./install --list` | Lists module names, supported platforms, and descriptions. |
| `./install --status` | Runs installation probes for modules supported on the current platform. |
| `./install --verbose ...` | Enables detailed progress output for an installation. |
| `./install --help` | Prints the command summary. |

Install mode can use package managers, `sudo`, remote installers, and GNU Stow.
Review a selection first when running the repository on a new machine.

## Modules

The `Default` column shows which modules are preselected by `./install` on a
supported platform. Dependencies are installed before the selected module.

| Module | Platforms | Default | Dependencies | Purpose |
| --- | --- | --- | --- | --- |
| `desktop` | macOS | on | `must-have`, `git`, `media`, `fs` | macOS command-line and desktop software, including Hammerspoon, WezTerm, Kitty, and application casks. |
| `docker` | macOS, Linux | off | — | Docker Desktop on macOS or Docker Engine on Debian, plus the Oxker and LazyDocker terminal interfaces. The Linux setup currently supports Debian only. |
| `fs` | macOS, Linux | off | `media`, `must-have` | Navigation, search, inspection, file-manager, archive, and disk-usage tools, including Yazi and Midnight Commander. |
| `git` | macOS, Linux | on | `ssh` | Git, GitHub CLI, Git LFS, delta, LazyGit, Tig, shared configuration, semantic diff tooling on macOS, and a TUI diff reviewer (revdiff) on macOS. |
| `homebrew` | macOS | on | — | Homebrew itself, a package-metadata refresh, and the `brew-snapshot` Brewfile helper. The installer bootstraps Homebrew for every macOS run, so other modules do not depend on this one. |
| `linux` | Linux | on | `must-have` | Debian/Ubuntu command-line tools, certificates, terminal data, and build prerequisites. |
| `media` | macOS, Linux | off | — | FFmpeg, ImageMagick with its Ghostscript and librsvg delegates, MediaInfo, ExifTool, Poppler, qpdf, Pandoc, Chafa, Tesseract, SoX, and yt-dlp. LibreOffice is installed on macOS only. |
| `mise` | macOS, Linux | off | — | Per-project tool versions with mise, including `.nvmrc` and `.tool-versions` support. The Linux setup uses the upstream APT repository on Debian and Ubuntu, amd64 and arm64. |
| `multiplexer` | macOS, Linux | off | — | tmux with TPM-managed plugins and the Herdr agent multiplexer. |
| `must-have` | macOS, Linux | on | — | Cross-platform baseline tools such as curl, wget, rsync, htop, btop, Micro, Make, Just, direnv, and fzf. |
| `node24` | macOS, Linux | off | — | Node.js 24 and npm through Homebrew or the NodeSource repository. The Linux setup supports Debian and Ubuntu. |
| `nvim` | macOS, Linux | on | — | Neovim with an NvChad configuration, plugins, and supporting tools. Official Linux builds require glibc 2.34 or later. |
| `php85` | macOS, Linux | off | — | PHP 8.5 with the common extensions and Composer, pinned against minor-version drift. Sury on Debian, the `php@8.5` formula on macOS. |
| `python` | macOS, Linux | off | — | uv with a managed CPython interpreter, Ruff, mypy, ty, pre-commit, IPython, pip-audit, nox, and user-level uv and REPL configuration. |
| `rust` | macOS, Linux | off | — | The stable Rust toolchain through rustup with Clippy, rustfmt, rust-analyzer, and the cargo-binstall, nextest, audit, edit, and sccache tools. |
| `ssh` | macOS, Linux | on | — | OpenSSH client defaults with connection multiplexing, an agent helper for Linux, includes for private per-host configuration, keychain, ssh-audit, sshuttle, and autossh. |
| `zsh` | macOS, Linux | off | — | Zsh with a modular Zinit-based configuration, the Powerlevel10k prompt, and plugin warm-up. |

Every module contains a `README.md` with its packages, configuration, setup
behavior, and platform-specific limitations.

## Profiles

Profiles are plain files under `profiles/`. Blank lines and lines beginning
with `#` are ignored.

| Profile | Modules | Intended use |
| --- | --- | --- |
| `code` | `php85`, `node24`, `rust`, `python`, `mise` | Language toolchains. `mise` layers per-project versions over the fixed toolchains. |
| `docker` | `git`, `fs`, `zsh` | A container-oriented interactive shell environment. This profile does not install Docker Engine or Docker Desktop. |
| `linux` | `linux`, `docker`, `git`, `must-have`, `media`, `fs` | Debian server and command-line environment. |
| `mac` | `homebrew`, `must-have`, `docker`, `git`, `media`, `fs`, `nvim`, `multiplexer`, `desktop`, `zsh`, `ssh` | Full macOS workstation environment. |

Dependencies are added automatically. Modules unsupported on the current
platform are reported and skipped.

To add a profile, create `profiles/<name>` with whitespace-delimited module
names, conventionally one per line:

```text
git
fs
zsh
```

Resolve it without installing anything:

```bash
./install --profile <name> --select
```

## Adding a module

Create `modules/<name>/` with the required `module.conf` and `README.md`. A
minimal manifest looks like this:

```bash
description="Zsh and shell plugins"
platforms="mac linux"
deps=""
default="off"
probe="command -v zsh >/dev/null"
```

The manifest is sourced as trusted Bash code. Its supported fields are:

| Field | Meaning |
| --- | --- |
| `description` | Short description shown by the list and picker commands. |
| `platforms` | Space-separated `mac` and/or `linux`; defaults to both. |
| `deps` | Space-separated module dependencies. |
| `default` | `on` or `off`; defaults to `off`. |
| `probe` | Non-interactive shell command whose status indicates whether the module is installed. |

A module may also provide:

```text
modules/<name>/
├── module.conf       # Required module metadata
├── packages.apt      # One APT package token per non-comment line
├── packages.brew     # One Homebrew formula token per non-comment line
├── casks.brew        # One Homebrew cask token per non-comment line
├── config/           # Files mirrored into $HOME through GNU Stow
├── setup.sh          # Module-specific setup after packages and Stow
└── README.md         # Required module documentation
```

`setup.sh` receives `OS`, `DOTFILES_DIR`, and `MODULE_DIR` in its environment.
Keep it compatible with Bash 3.2, non-interactive, and safe to run repeatedly.

Only `config/` is passed to Stow. Mirror each target path relative to `$HOME`:

```text
modules/zsh/config/.zshrc       -> ~/.zshrc
modules/nvim/config/.config/nvim -> ~/.config/nvim
```

Before Stow runs, a conflicting regular file or foreign symbolic link is moved
to a timestamped directory under `.backups/` in the repository. Links already owned by
this repository are restowed. Targets beneath a symlinked parent directory are
left untouched to avoid modifying files outside the expected home path.

## Repository structure

```text
.
├── AGENTS.md          # Repository instructions for coding agents
├── README.md          # Project overview and usage
├── install            # Installer entry point
├── lib/
│   ├── common.sh      # OS, package manager, backup, and Stow helpers
│   ├── modules.sh     # Metadata, dependencies, profiles, and probes
│   └── picker.sh      # Interactive selector
├── modules/
│   └── <name>/        # Module metadata, packages, config, and setup
└── profiles/          # Named module selections
```

## Development

Validate shell syntax after changing installer or setup code:

```bash
bash -n install lib/*.sh modules/*/setup.sh
```

Run ShellCheck when it is available:

```bash
shellcheck --shell=bash install lib/*.sh modules/*/setup.sh
```

Useful read-only smoke checks are:

```bash
./install --list
./install --select </dev/null
```

Validate every entry in a changed profile without installation by passing its
contents explicitly. This also catches unknown or platform-specific modules:

```bash
# Intentional word splitting: profiles use the installer's whitespace protocol.
./install --select $(awk '!/^[[:space:]]*(#|$)/ { print }' profiles/<name>)
```

Do not run a real installation merely as a development check because it can
install packages, modify system files, and link configuration into `$HOME`.

## Security

Before every commit or deployment, review all changed files for tokens,
credentials, API keys, access details, personal names, email addresses, private
URLs, hostnames, and other personal or account data. Keep secrets and
machine-specific values in appropriate untracked local files.
