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
| [Tig](https://jonas.github.io/tig/) | Browses history, blame, and stashes in a keyboard-driven pager. |
| [sem](https://ataraxy-labs.github.io/sem/) | Provides entity-level semantic diff through `git sdiff` on macOS. |
| [revdiff](https://github.com/umputun/revdiff) | Reviews diffs, files, and documents with inline annotations in a TUI, through the Zsh module's `rd` alias. |

`sem-cli` is only present in the Homebrew manifest. The `sdiff` alias checks
for the command and prints an error when it is unavailable.

`revdiff` is also only present in the Homebrew manifest, from the third-party
`umputun/apps` tap, and only on macOS.

## Configuration layout

GNU Stow links the following entry points and support files:

| Target | Purpose |
| --- | --- |
| `~/.gitconfig` | Includes the tracked modular configuration and then the optional `~/.gitconfig.local`. |
| `~/.config/git/.gitconfig` | Includes each tracked concern plus optional `work.conf` and `personal.conf`. |
| `~/.config/git/.gitignore` | Supplies global ignore rules through `core.excludesFile`. |
| `~/.config/git/.gitattributes` | Supplies global text and binary attributes through `core.attributesFile`. |
| `~/.config/lazygit/config.yml` | Configures LazyGit's UI, refresh behavior, editor, and delta pager. |

### LazyGit configuration path on macOS

Go's `os.UserConfigDir` hardcodes `~/Library/Application Support` on macOS and
ignores `XDG_CONFIG_HOME`, so LazyGit never looks at the Stow-linked
`~/.config/lazygit/config.yml` there. `setup.sh` mirrors it by symlinking
`~/Library/Application Support/lazygit/config.yml` to the stowed file after
every install run. The fix is skipped on Linux (LazyGit does read
`~/.config/lazygit` there) and leaves a pre-existing non-empty file at that
path alone, warning instead of overwriting it.

The tracked Git configuration is split by concern:

- `core.conf` controls pull, apply, branch, tag, column, commit, blame, help,
  merge, rerere, rebase, fetch, push, init, global ignore, and global attributes
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
- `urls.conf` defines the `gh:`, `github:`, `gst:`, and `gist:` shorthands.
  `gh:`/`gst:` clone over SSH; `github:`/`gist:` clone anonymously over HTTPS
  and push over SSH. Both also rewrite the `git://` scheme GitHub shut down in
  2022, so a remote still recorded with it fetches over HTTPS.
- `lfs.conf` wires the Git LFS clean, smudge, and process filters.
- `signing.conf` selects the SSH signature format and the allowed-signers file.
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
| `bl` | Blames while ignoring whitespace, following moved code, and skipping `.git-blame-ignore-revs` when the repository ships one. |
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
| `maint <subcommand>` | Runs `git maintenance` with the repository list redirected to `~/.gitconfig.local`. |
| `aliases` / `contributors` / `whoami` | Lists aliases / contributor counts / the configured email. |

`ca`, `reb`, and `tags` rely on `commit.verbose`, `rebase.autosquash`, and
`tag.sort` from `core.conf`, so `aliases.conf` and `core.conf` should remain
synchronized.

## Ignoring bulk reformats in blame

`blame.ignoreRevsFile` is not set globally. The setting names one path for every
repository, and Git aborts wherever that path is missing:

```
fatal: could not open object name list: .git-blame-ignore-revs
```

The `bl` alias passes `--ignore-revs-file` per invocation instead, and only when
the current repository actually contains `.git-blame-ignore-revs` at its root,
so a repository without the file still blames normally. Record the commit of a
bulk reformat there, one unabbreviated SHA per line, and `git bl` attributes the
lines to their previous author. `blame.markIgnoredLines` and
`blame.markUnblamableLines` in `core.conf` mark the results Git had to guess
(`?`) or could not attribute at all (`*`).

## Signing commits with an SSH key

`signing.conf` selects the SSH backend (`gpg.format = ssh`) and points
`gpg.ssh.allowedSignersFile` at `~/.config/git/allowed_signers`. No gnupg
installation is involved: the key is an ordinary SSH keypair, and verification
reads a text file.

Signing itself stays off in the tracked configuration. `commit.gpgsign = true`
without a configured key fails every commit with `fatal: either
user.signingkey or gpg.ssh.defaultKeyCommand needs to be configured`, so the
key and the switch are set together in `personal.conf`, `work.conf`, or
`~/.gitconfig.local`:

```ini
[user]
    email = you@example.com
    signingkey = ~/.ssh/id_ed25519.pub
[commit]
    gpgsign = true
[tag]
    gpgSign = true
```

The allowed-signers file is created locally and holds one line per identity, so
verification can name a signer instead of reporting `No principal matched`:

```bash
echo "you@example.com $(cat ~/.ssh/id_ed25519.pub)" >> ~/.config/git/allowed_signers
```

Neither the key path nor that file is tracked. On GitHub the same public key
must be added a second time as a signing key; an authentication key with
identical bytes leaves commits unverified.

## Background maintenance

`git maint start` registers the current repository with Git's scheduled
maintenance — hourly prefetch, daily incremental repack and loose-object
cleanup, weekly `gc` — and installs the platform scheduler entry (launchd on
macOS, systemd timers or cron on Linux). `git maint unregister` removes the
repository from the list, and `git maint stop` also removes the scheduler entry.
Registration writes `maintenance.auto = false` and `maintenance.strategy =
incremental` into the repository's own `.git/config`, which is what stops
foreground `gc` from interrupting a command.

The alias exists because of the stow layout. `git maintenance` stores the
repository list in the global configuration, and `~/.gitconfig` is a symlink
into this repository: Git follows it and writes the machine's absolute paths
into a tracked file. The alias sets `GIT_CONFIG_GLOBAL=~/.gitconfig.local` for
the duration of the command, so the entries land in the untracked file that
`~/.gitconfig` includes, and the scheduled `git for-each-repo
--config=maintenance.repo` still finds them.

The same hazard applies to any `git config --global` run on these machines: the
write lands in `modules/git/config/.gitconfig`. Check `git status` in the
dotfiles repository after one, or write to `~/.gitconfig.local` with
`git config --file ~/.gitconfig.local` instead.
