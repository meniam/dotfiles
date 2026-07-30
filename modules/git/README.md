# Git

Git and GitHub command-line tooling.

| Utility | Purpose |
| --- | --- |
| [Git](https://git-scm.com/) | Distributed version control. |
| [GitHub CLI](https://cli.github.com/) | Manages GitHub repositories, issues, and pull requests from the terminal. |
| [Git LFS](https://git-lfs.com/) | Versions large files alongside a Git repository. |
| [delta](https://github.com/dandavison/delta) | Syntax-highlighting pager for Git diffs. |
| [LazyGit](https://github.com/jesseduffield/lazygit) | Terminal user interface for staging, committing, and reviewing Git changes. |
| [sem](https://ataraxy-labs.github.io/sem/) | Entity-level semantic diff and blame, used by the `git sdiff` alias. macOS only; the alias degrades to an error message elsewhere. |

The module installs LazyGit and links its configuration file to `~/.config/lazygit`. It also links a global gitignore and gitattributes to `~/.config/git/.gitignore` / `~/.config/git/.gitattributes`, pointing `core.excludesfile` / `core.attributesfile` at them.

`~/.config/git/.gitconfig` is just a manifest of `[include]`s, one per logical concern:

- `core.conf` — pull/apply/branch/tag/column/core/commit/help/merge/rerere/rebase/fetch/push/init behavior.
- `color.conf` — terminal color settings.
- `diff.conf` — generic diff behavior (histogram algorithm, rename detection, binary diff via `hexdump`).
- `urls.conf` — `gh:`/`github:`/`gst:`/`gist:` URL shorthands.
- `aliases.conf` — the aliases plus the shared `[pretty] brief` commit format they log with.
- `lfs.conf` — Git LFS filter wiring.
- `delta.conf` — delta pager settings.

It also `[include]`s `work.conf` and `personal.conf` for machine-specific `[user]` identity and other personal overrides (e.g. `diff.external`). Neither file is part of the module; both are gitignored by the dotfiles repo and meant to be created locally per machine — Git silently skips an `[include]` whose target does not exist.

`~/.config/git/.gitconfig` is not one of Git's auto-discovered config paths (those are `~/.gitconfig` and `~/.config/git/config`), so something has to pull it in. That job belongs to `config/.gitconfig`, which stow links to `~/.gitconfig` along with the rest of the package: it is a two-line manifest that `[include]`s `~/.config/git/.gitconfig` and then `~/.gitconfig.local`.

Wiring it this way rather than through `git config --global include.path` keeps the whole chain declarative — `stow -D` removes it as cleanly as it was added, and no install step mutates a file outside the module. `~/.gitconfig.local` is the per-machine escape hatch and is not part of the repository.

## Aliases

Single-letter names are the ones typed dozens of times a day; the shell also has `alias g='git'`, so these are usually entered as `g s`, `g l`, `g d`. `git aliases` prints the live list.

| Alias | Does |
| --- | --- |
| `s` | Short status with branch and upstream tracking. |
| `l` / `lg` | Graph log of the last 20 commits on this branch / of every ref, unlimited. |
| `d` / `di N` | Diff the working tree against the last commit / against the state N commits ago. |
| `last` | The last commit plus its diffstat. |
| `bl` | Blame ignoring whitespace and following moved code. |
| `root` | Absolute path of the repository root. |
| `sdiff` | Entity-level semantic diff via `sem`, accepting `git diff` syntax. |
| `ca` | Stage everything, including deletions, and commit. |
| `amend` / `reword` | Fold staged changes into the last commit / re-edit only its message. |
| `credit "Name" mail@host` | Reassign authorship of the last commit. |
| `fix <commit>` | Commit a `fixup!` for `<commit>`, squashed later by `reb`. |
| `undo` | Drop the last commit, keeping its changes staged. |
| `unstage <path>` | Unstage paths without touching the working tree. |
| `wip` | Stash everything, untracked files included. |
| `go <branch>` | Switch to a local branch, to a new branch tracking `origin/<branch>`, or create one off HEAD. |
| `branches` | Local and remote branches with tracking info and last commit. |
| `defbranch` | Name of the remote's default branch, falling back to `main`. |
| `dm` | Delete local branches already merged into the default branch. Skips `main`/`master`/`dev` and checked-out branches. |
| `reb N` | Interactive rebase of the last N commits (default 10), autosquashing fixups. |
| `pf` | Force-push the current branch without discarding unseen upstream commits. |
| `fc` / `fm` | Find commits by code change / by commit message. |
| `fb` / `ft` | Find branches / the nearest tag containing a commit. |
| `p` / `c` | Pull / clone, submodules included. |
| `tags` / `remotes` | Tags newest-version-first / remotes with fetch and push URLs. |
| `retag <tag>` | Move an existing tag to the current commit, locally and on `origin`. |
| `aliases` / `contributors` / `whoami` | List aliases / contributors by commit count / this repository's user email. |

Three aliases lean on settings that live in `core.conf` rather than repeating the flag themselves, so the two files have to ship together: `ca` on `commit.verbose`, `reb` on `rebase.autosquash`, `tags` on `tag.sort`.
