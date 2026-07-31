# Contributing

Contributions should keep this repository portable, predictable, and safe to
apply to an existing home directory. Prefer focused changes that solve one
problem without introducing unrelated configuration or generated state.

Read [README.md](README.md) for the user-facing module and installer model.
Coding agents must also follow [AGENTS.md](AGENTS.md) and any nested
`AGENTS.md` that applies to the files being changed.

## Supported environments

The installer supports:

- macOS with Homebrew and Bash 3.2 or later
- Debian/Ubuntu Linux with Bash and `apt-get`

Individual modules may support a narrower platform or distribution. Keep those
restrictions explicit in `module.conf`, setup guards, and documentation. Do not
claim support for an environment that has not been handled by the code.

## Project conventions

- Write source code, comments, command output, documentation, branch names, and
  commit messages in English.
- Keep `install` as the installer entry point and shared shell behavior in
  `lib/`.
- Keep module-specific packages, setup, and configuration under
  `modules/<name>/`.
- Keep all installer and setup scripts compatible with Bash 3.2. Avoid Bash 4+
  features such as associative arrays, `mapfile`, and case conversion.
- Prefer cross-platform commands and flags. Guard platform-specific behavior
  with the detected `OS` or an explicit distribution check.
- Keep machine-readable output on stdout and prompts, progress, warnings, and
  errors on stderr.
- Do not commit machine-specific values, personal data, credentials, tokens,
  private URLs, hostnames, generated caches, or runtime state.

## Branch workflow

`main` is the stable branch and `dev` is the integration branch for ongoing
work.

1. Update `dev` and create a focused branch from it.
2. Use a lowercase, hyphen-separated branch name such as
   `feat/<description>`, `fix/<description>`, `docs/<description>`, or
   `chore/<description>`.
3. Keep one purpose per branch and avoid unrelated cleanup.
4. Open the pull request against `dev` unless a maintainer requests another
   target.
5. Delete the branch after it is merged.

Changes promoted from `dev` to `main` should already be reviewed and validated.

## Modules

Every module lives in `modules/<name>/` and must contain both `module.conf` and
`README.md`:

```text
modules/<name>/
├── module.conf       # Required metadata
├── packages.apt      # Optional APT packages
├── packages.brew     # Optional Homebrew formulae
├── casks.brew        # Optional Homebrew casks
├── config/           # Optional $HOME-relative Stow payload
├── setup.sh          # Optional post-package, post-Stow setup
└── README.md         # Required module documentation
```

Keep `module.conf` declarative. It is sourced as trusted Bash and supports the
following assignments:

- `description`: short user-facing description
- `platforms`: space-separated `mac` and/or `linux`
- `deps`: space-separated module dependencies
- `default`: `on` or `off`
- `probe`: non-interactive command that reports installation state through its
  exit status

Dependencies must exist and remain acyclic. Package manifests contain one
package token per non-comment line.

Keep `README.md` aligned with the manifest, package lists, Stow payload, setup
side effects, installation probe, supported environments, and limitations.

### Setup scripts

`setup.sh` runs after package installation and Stow. It receives `OS`,
`DOTFILES_DIR`, and `MODULE_DIR` in its environment.

- Use `#!/usr/bin/env bash` and `set -euo pipefail`.
- Keep the script non-interactive and idempotent.
- Reuse helpers from `lib/common.sh` for logging, package installation,
  timeouts, and OS detection.
- Check whether the desired state already exists before downloading or
  replacing it.
- Use temporary files or directories for downloads and clean them on success,
  failure, and interruption.
- Validate prerequisites and downloaded artifacts before replacing an existing
  installation.
- Explain any unavoidable platform or architecture limitation in the module's
  documentation.

### Configuration payloads

Files under `config/` mirror their destination relative to `$HOME` and are
linked by GNU Stow. For example:

```text
modules/zsh/config/.zshrc -> ~/.zshrc
```

Keep personal identities, secrets, host-specific values, and local overrides
out of tracked payloads. Prefer an ignored local include when an application
supports one. Do not track generated caches, plugin state, or lock files unless
the change specifically requires a reproducible artifact.

## Profiles

Profiles live in `profiles/<name>` and contain whitespace-delimited module
names, conventionally one per line. Blank lines and lines beginning with `#`
are ignored.

- Reference only existing modules.
- Rely on module dependencies instead of listing a dependency solely to force
  ordering.
- Keep the profile name and comment aligned with its intended environment.
- Update the profile table in `README.md` when a profile is added, removed,
  renamed, or repurposed.

## Documentation

Update existing documentation when a change affects commands, module contents,
dependencies, defaults, profiles, supported platforms, prerequisites, linked
paths, or installation behavior.

Keep the root `README.md` concise and user-facing. Put detailed tool lists,
configuration behavior, and application-specific caveats in the relevant
module's `README.md`.

## Commit messages

Use Conventional Commits:

```text
<type>[optional scope]: <subject>

[optional body]

[optional footer(s)]
```

Allowed types are `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`,
`build`, `ci`, `chore`, and `revert`.

- Add a scope when it clearly identifies the affected module or area, such as
  `zsh`, `fs`, `profiles`, or `installer`.
- Write the subject as a concise, imperative, lowercase English phrase without
  a final period.
- Prefer a subject of 50 characters or fewer and never exceed 72 characters.
- Use the body to explain motivation, non-obvious tradeoffs, or behavior that
  the subject cannot capture. Wrap prose near 72 characters.
- Reference an issue only when the identifier is confirmed.
- Mark a breaking change with `!` and/or a `BREAKING CHANGE:` footer that
  explains its impact and migration path.
- Keep commits atomic and leave the repository in a working state after each
  commit.

Examples:

```text
feat(zsh): add project navigation helper
fix(installer): preserve foreign symlinks
docs(profiles): document the mac profile
chore(fs): update package manifests
```

## Validation

Run checks proportional to the change. Validate all changed Bash entry points
and setup scripts with:

```bash
bash -n install lib/*.sh modules/*/setup.sh
```

Run ShellCheck when it is available:

```bash
shellcheck --shell=bash install lib/*.sh modules/*/setup.sh
```

Safe read-only smoke checks include:

```bash
./install --list
./install --select </dev/null
```

Validate every entry in a changed profile by passing its contents explicitly.
This catches unknown and platform-specific modules without running an install:

```bash
# Intentional word splitting: profiles use the installer's whitespace protocol.
./install --select $(awk '!/^[[:space:]]*(#|$)/ { print }' profiles/<name>)
```

Run application-specific syntax or configuration checks for changed payloads
when the application is available. For platform-specific changes, state which
supported environments were exercised and which remain untested.

Do not run install mode merely as a validation shortcut. It may invoke package
managers, `sudo`, remote installers, module setup scripts, conflict backups,
and GNU Stow. When end-to-end installation is necessary, use a disposable
supported environment where possible and document the resulting system and
home-directory changes.

## Pull requests

A pull request should include:

- the problem and the intended outcome
- the user-visible or operational behavior that changed
- the validation commands and environments used
- skipped checks or remaining platform coverage
- migration steps and breaking changes, when applicable
- confirmed issue references, when applicable

Use a concise English title, preferably in Conventional Commit form. Keep the
diff free of unrelated cleanup, generated files, secrets, and machine-specific
values. Review the final diff and resolve review comments before merging.

## Security review

Before every commit and deployment, inspect all changed files for credentials,
tokens, API keys, access details, personal names, email addresses, private URLs,
hostnames, and other account or machine-specific data. Remove such information
or move it to an appropriate untracked local file before proceeding.
