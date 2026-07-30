# Git

Git and GitHub command-line tooling.

| Utility | Purpose |
| --- | --- |
| [Git](https://git-scm.com/) | Distributed version control. |
| [GitHub CLI](https://cli.github.com/) | Manages GitHub repositories, issues, and pull requests from the terminal. |
| [Git LFS](https://git-lfs.com/) | Versions large files alongside a Git repository. |
| [delta](https://github.com/dandavison/delta) | Syntax-highlighting pager for Git diffs. |
| [LazyGit](https://github.com/jesseduffield/lazygit) | Terminal user interface for staging, committing, and reviewing Git changes. |

The module installs LazyGit and links its configuration file to `~/.config/lazygit`. It also links a global gitignore and gitattributes to `~/.config/git/.gitignore` / `~/.config/git/.gitattributes`, pointing `core.excludesfile` / `core.attributesfile` at them.

`~/.config/git/.gitconfig` is just a manifest of `[include]`s, one per logical concern:

- `core.conf` — pull/apply/branch/core/commit/help/merge/push/init behavior.
- `color.conf` — terminal color settings.
- `diff.conf` — generic diff behavior (rename detection, binary diff via `hexdump`).
- `urls.conf` — `gh:`/`github:`/`gst:`/`gist:` URL shorthands.
- `lfs.conf` — Git LFS filter wiring.
- `aliases.conf` — Git aliases.
- `delta.conf` — delta pager settings.

It also `[include]`s `work.conf` and `personal.conf` for machine-specific `[user]` identity and other personal overrides (e.g. `diff.external`). Neither file is part of the module; both are gitignored by the dotfiles repo and meant to be created locally per machine — Git silently skips an `[include]` whose target does not exist.

`~/.config/git/.gitconfig` is not one of Git's auto-discovered config paths (those are `~/.gitconfig` and `~/.config/git/config`), so `setup.sh` wires it in with `git config --global include.path ~/.config/git/.gitconfig`.
