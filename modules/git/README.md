# Git

Git and GitHub command-line tooling with a modular global configuration.

- Platforms: macOS and Linux
- Default: on
- Dependencies: none

## Included tools

| Utility | Purpose |
| --- | --- |
| [Git](https://git-scm.com/) | Distributed version control. |
| [GitHub CLI](https://cli.github.com/) | Manages GitHub repositories, issues, pull requests, and authentication. |
| [Git LFS](https://git-lfs.com/) | Versions large files alongside a Git repository. |
| [delta](https://github.com/dandavison/delta) | Renders syntax-highlighted, side-by-side Git output. |
| [LazyGit](https://github.com/jesseduffield/lazygit) | Provides an interactive terminal interface for Git. |
| [sem](https://ataraxy-labs.github.io/sem/) | Provides entity-level semantic diff through `git sdiff` on macOS. |

`sem-cli` is only present in the Homebrew manifest. The `sdiff` alias checks
for the command and prints an error when it is unavailable.

## Configuration layout

GNU Stow links the following entry points and support files:

| Target | Purpose |
| --- | --- |
| `~/.gitconfig` | Includes the tracked modular configuration and then the optional `~/.gitconfig.local`. |
| `~/.config/git/.gitconfig` | Includes each tracked concern plus optional `work.conf` and `personal.conf`. |
| `~/.config/git/.gitignore` | Supplies global ignore rules through `core.excludesFile`. |
| `~/.config/git/.gitattributes` | Supplies global text and binary attributes through `core.attributesFile`. |
| `~/.config/lazygit/config.yml` | Configures LazyGit's UI, refresh behavior, editor, and delta pager. |

The tracked Git configuration is split by concern:

- `core.conf` controls pull, apply, branch, tag, column, commit, help, merge,
  rerere, rebase, fetch, push, init, global ignore, and global attributes
  behavior.
- `color.conf` uses terminal palette names for Git output and configures blame
  annotations by age.
- `diff.conf` uses the histogram algorithm, detects copies, and defines a
  `hexdump` text conversion for binary files. Moved-line colouring is available
  per command but intentionally disabled globally because it is noisy on
  repetitive generated files.
- `delta.conf` enables navigation, hyperlinks, line numbers, side-by-side
  wrapping, ANSI syntax colours, interactive-patch overrides, blame syntax,
  and `zdiff3` merge conflicts.
- `urls.conf` defines `gh:`, `github:`, `gst:`, and `gist:` shorthands.
- `lfs.conf` wires the Git LFS clean, smudge, and process filters.
- `aliases.conf` contains the aliases and shared `pretty.brief` log format.

`work.conf` and `personal.conf` are ignored repository-local files for identity
and environment-specific settings. Git silently skips them when absent.
`~/.gitconfig.local` is a second machine-local escape hatch outside the
repository.

This include chain is declarative: Stow creates and removes `~/.gitconfig`, and
the module does not need to mutate Git's global configuration with
`git config --global`.

## Aliases

The Zsh module also defines `g=git`, so short aliases are commonly entered as
`g s`, `g l`, or `g d`. Run `git aliases` to inspect the live set.

| Alias | Behavior |
| --- | --- |
| `s` | Shows short status with branch and upstream tracking. |
| `l` / `lg` | Shows the latest 20 commits on the current branch / unlimited history across all refs. |
| `d` / `di N` | Diffs the working tree against the last commit / the state `N` commits ago. |
| `last` | Shows the latest commit and its diffstat. |
| `bl` | Blames while ignoring whitespace and following moved code. |
| `root` | Prints the repository root. |
| `sdiff` | Runs an entity-level semantic diff through `sem`. |
| `ca` | Stages every change, including deletions, and commits. |
| `amend` / `reword` | Amends with the existing message / edits only the latest message. |
| `credit "Name" mail@host` | Reassigns authorship of the latest commit. |
| `fix <commit>` | Creates a `fixup!` commit for later autosquashing. |
| `undo` | Removes the latest commit while keeping its changes staged. |
| `unstage <path>` | Unstages paths without modifying the working tree. |
| `wip` | Stashes tracked and untracked changes. |
| `go <branch>` | Switches to a local or remote-tracking branch, or creates a new branch. |
| `branches` | Lists local and remote branches with tracking details. |
| `defbranch` | Prints the remote default branch, falling back to `main`. |
| `dm` | Deletes merged local branches except `main`, `master`, `dev`, and checked-out branches. |
| `reb N` | Interactively rebases the latest `N` commits, defaulting to 10, with autosquash. |
| `pf` | Force-pushes with lease and unseen-upstream protection. |
| `fc` / `fm` | Searches commits by changed content / commit message. |
| `fb` / `ft` | Finds branches / the nearest tag containing a commit. |
| `p` / `c` | Pulls / clones with submodules. |
| `tags` / `remotes` | Lists version-sorted tags / configured remotes. |
| `retag <tag>` | Moves an existing tag to `HEAD` locally and on `origin`. |
| `aliases` / `contributors` / `whoami` | Lists aliases / contributor counts / the configured email. |

`ca`, `reb`, and `tags` rely on `commit.verbose`, `rebase.autosquash`, and
`tag.sort` from `core.conf`, so `aliases.conf` and `core.conf` should remain
synchronized.
