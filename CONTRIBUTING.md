# Contributing

Thank you for improving these dotfiles. Keep changes small, focused, and
portable across the supported platforms whenever possible.

## Project conventions

- Use English for source code, comments, command output, documentation, and
  commit messages.
- Keep installer code compatible with Bash 3.2 on macOS and Bash on
  Debian/Ubuntu Linux.
- Preserve the installer layout: `install` is the entry point and `lib/`
  contains shared helpers.
- Do not add machine-specific values, personal data, credentials, tokens, or
  private URLs to tracked files.

## Branches

- Keep `main` deployable and use it only for reviewed, merged changes.
- Create a focused branch from the latest `main` for each independent change.
- Name branches in lowercase English with hyphen-separated words:
  `feat/<short-description>`, `fix/<short-description>`,
  `docs/<short-description>`, or `chore/<short-description>`.
- Keep one purpose per branch. Split unrelated work into separate branches.
- Delete a branch after its pull request is merged.

## Adding or changing a module

Modules live in `modules/<name>/`. A module must include `module.conf` and can
optionally include package manifests, `setup.sh`, and a `config/` directory.
Files below `config/` mirror their destination below `$HOME` and are linked by
GNU Stow.

```text
modules/<name>/
├── module.conf
├── packages.apt
├── packages.brew
├── casks.brew
├── setup.sh
└── config/
```

Keep `setup.sh` idempotent. Add a platform guard before platform-specific
commands, and use untracked local overrides for machine-specific settings.

## Commit messages

Use Conventional Commits:

    <type>[optional scope]: <subject>

    [optional body]

    [optional footer(s)]

- Use one of: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`,
  `test`, `build`, `ci`, `chore`, or `revert`.
- Use an optional scope only when it identifies a clear area, such as
  `zsh`, `yazi`, `hammerspoon`, or `installer`.
- Write the subject in concise, imperative English. Start it in lowercase,
  omit a final period, and prefer 50 characters or fewer; never exceed 72.
- Add a body only when the result or reason needs clarification. Wrap body
  lines near 72 characters.
- Add ticket footers only for confirmed references, for example `Closes #123`.
- Mark confirmed breaking changes with `!` in the header and/or a
  `BREAKING CHANGE:` footer, including the impact and migration path when
  known.
- Make commits atomic. Each commit must leave the repository in a working
  state and must not combine independent purposes.

Examples:

    feat(zsh): add weather helper
    fix(hammerspoon): select US input source
    docs: add contribution guide
    chore: update package manifests

## Validation

Run the relevant checks before opening a pull request:

```bash
bash -n install lib/*.sh
shellcheck --shell=bash install lib/*.sh
./install --list
./install --select
```

Run ShellCheck when it is available. For a module change, also install or
exercise the affected module on a supported platform.

## Pull requests

- Open a pull request from a focused branch into `main`.
- Use an English title that summarizes the observable change; use the
  Conventional Commit format when it fits.
- Describe the purpose, user-visible behavior, validation performed, and any
  manual verification that reviewers need to repeat.
- Link an issue only when a confirmed issue exists. Call out breaking changes,
  migration steps, and platform-specific behavior explicitly.
- Keep the pull request free of unrelated cleanup, generated files, secrets,
  and machine-specific values.
- Review the diff and resolve all comments before merging.

## Before committing

Review every changed file for sensitive information, including credentials,
tokens, API keys, access details, personal names, email addresses, private
URLs, hostnames, and account data. Remove such information or move it to an
appropriate untracked local file before committing.

Follow the commit message rules above.
