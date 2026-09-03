# Multiplexer

Terminal multiplexing for regular shell sessions and coding-agent workflows.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none

## Included tools

| Utility | Purpose |
| --- | --- |
| [tmux](https://github.com/tmux/tmux) | Keeps terminal sessions and panes running independently of a terminal window. |
| [TPM](https://github.com/tmux-plugins/tpm) | Installs and updates the plugins declared by `tmux.conf`. |
| [Herdr](https://herdr.dev) | Organizes coding agents, terminals, tabs, worktrees, and restored sessions. |

## Configuration

| Target | Purpose |
| --- | --- |
| `~/.config/tmux/tmux.conf` | Configures the `Ctrl-A` prefix, one-based windows and panes, mouse support, vi copy mode, clipboard integration, status widgets, and TPM plugins. |
| `~/.config/tmux/yank.sh` | Copies through native clipboard tools, a remote tunnel, or OSC 52. |
| `~/.config/tmux/renew_env.sh` | Refreshes selected environment variables in live shell panes. |
| `~/.config/tmux/tmux.remote.conf` | Provides an optional remote-session status layout and clipboard tunnel port. It is bundled but not sourced automatically. |
| `~/.config/herdr/config.toml` | Selects Zsh, a `Ctrl-A` prefix, Tokyo Night styling, agent labels, worktree storage, session restore, sound, splits, pane navigation, and file-viewer commands. |
| `~/.config/herdr/scripts/toggle-split.sh` | Creates a right split when a tab has one pane, otherwise focuses a neighboring pane. Bound to `Ctrl-A a`. |

The tmux configuration declares battery, prefix highlighting, online status,
sidebar, copy/search, open, and system-statistics plugins. Several helper files
are based on `samoshkin/tmux-config` and remain tracked with this module.

## Installation behavior

`setup.sh` clones TPM into `~/.config/tmux/plugins/tpm` when missing and runs
TPM's plugin installer. It starts a tmux server for this process and finishes
with `tmux kill-server`; run the module only when stopping existing tmux
sessions is acceptable.

On macOS, Homebrew installs both tmux and Herdr. On Linux, APT installs tmux and
the setup script runs Herdr's official installer with a five-minute timeout.
Failure to install Herdr produces a warning rather than failing the whole setup,
but the module probe requires both `tmux` and `herdr`, so `./install --status`
reports an incomplete module until Herdr is available on `PATH`.
