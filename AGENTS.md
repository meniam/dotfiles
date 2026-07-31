# Repository Instructions

## Project scope

This is a modular dotfiles repository for macOS and Debian/Ubuntu Linux. It
contains the installer, shared shell helpers, opt-in modules, GNU Stow payloads,
and machine-role profiles.

- Keep the project, source comments, command output, documentation, and commit
  messages in English.
- Do not add, migrate, or generate modules, profiles, configuration payloads,
  templates, or documentation unless they are required by the user's task.
- Preserve unrelated work in the tree. Check `git status` and the relevant
  diffs before editing, and never discard changes you did not create.
- Instructions in a nested `AGENTS.md` apply in addition to this file and take
  precedence for files in that subtree.

## Repository layout

- `install` is the only installer entry point and owns argument parsing and the
  top-level install flow.
- `lib/common.sh` contains OS, package-manager, backup, and Stow helpers.
- `lib/modules.sh` contains module metadata, dependency, profile, and probe
  logic.
- `lib/picker.sh` contains the interactive selector. Its stdout is data; keep
  prompts and diagnostics on stderr.
- `modules/<name>/` contains one opt-in module and must include `module.conf`
  and `README.md`.
- `profiles/<name>` contains a whitespace-delimited list of module names, with
  blank lines and `#` comments allowed.

Keep shared behavior in `lib/` and module-specific behavior inside the relevant
module. Do not bypass the `install` entry point with a second installer.

## Shell compatibility and style

- Keep all installer and module setup code compatible with Bash 3.2 on macOS
  and Bash on Debian/Ubuntu Linux.
- Use `#!/usr/bin/env bash` for executable Bash scripts. Avoid Bash 4+ features
  such as associative arrays, `mapfile`, and case-conversion expansions.
- Quote expansions unless intentional word splitting is part of the existing
  whitespace-delimited module or package protocol; document intentional
  exceptions for ShellCheck.
- Prefer utilities and flags available on both supported platforms. Guard
  platform-specific commands with the detected `OS` or an explicit distro
  check.
- Keep setup operations non-interactive and idempotent. A repeated module run
  should converge without duplicating configuration or failing because an
  earlier run already completed part of the work.
- Reuse logging, package, timeout, and OS helpers from `lib/common.sh`. Preserve
  the convention that machine-readable results go to stdout and progress,
  warnings, and errors go to stderr.

## Module contract

`module.conf` is sourced as trusted Bash code. Keep it declarative and limit it
to these metadata assignments:

- `description`: short user-facing description.
- `platforms`: space-separated `mac` and/or `linux`; defaults to both.
- `deps`: space-separated module names; dependencies must exist and remain
  acyclic.
- `default`: `on` or `off`.
- `probe`: a non-interactive shell command whose exit status reports whether
  the module is installed.

A module may also contain:

- `packages.brew`: one Homebrew formula token per non-comment line.
- `casks.brew`: one Homebrew cask token per non-comment line.
- `packages.apt`: one APT package token per non-comment line.
- `config/`: files mirrored relative to `$HOME` and linked with GNU Stow.
- `setup.sh`: module-specific work run after package installation and Stow.

Every module must contain a `README.md` that documents its platforms, default
state, dependencies, included tools, configuration paths, setup side effects,
and relevant limitations. Keep it aligned with the module manifest and files.

`setup.sh` receives `OS`, `DOTFILES_DIR`, and `MODULE_DIR` in its environment.
It should use `set -euo pipefail`, source shared helpers when useful, validate
downloads before replacing an existing installation, and clean temporary files.
Do not embed secrets or machine-specific values in setup scripts or `config/`.

Treat paths below `config/` as literal `$HOME`-relative payloads. Do not commit
generated caches, runtime state, host-specific files, or application lock files
unless the task explicitly requires a reproducible tracked artifact.

## Profiles and documentation

- Profiles reference existing module names and rely on dependency resolution;
  do not duplicate dependencies merely to enforce ordering.
- Keep existing README command examples, module descriptions, profiles, and
  platform notes aligned when a task changes documented user-facing behavior.
- Do not claim support for a platform, architecture, package source, or command
  that the implementation does not handle.

## Validation

Run checks proportional to the change. For shell changes, start with:

```bash
bash -n install lib/*.sh modules/*/setup.sh
```

When ShellCheck is available, run:

```bash
shellcheck --shell=bash install lib/*.sh modules/*/setup.sh
```

Safe read-only smoke checks include:

```bash
./install --list
./install --select </dev/null
```

When module metadata or profiles change, validate every profile entry without
installing. Pass the entries explicitly so unknown or platform-specific modules
are not filtered out by the interactive picker:

```bash
# Intentional word splitting: profiles use the installer's whitespace protocol.
./install --select $(awk '!/^[[:space:]]*(#|$)/ { print }' profiles/<name>)
```

Add application-specific syntax or config checks for changed payloads when the
corresponding tool is available.

Do not run an actual installation merely as validation unless the user asks for
it. Install mode may install system packages, invoke `sudo`, download remote
artifacts, run module setup scripts, back up conflicts, and modify `$HOME`
through GNU Stow.

Before handing off a change, inspect the final diff and report the checks that
were run, including any check skipped because its tool was unavailable.

## Security

Before every commit or deployment, inspect all changed files for sensitive
information, including tokens, credentials, API keys, access details, personal
names, email addresses, private URLs, hostnames, and other personal or account
data. Do not commit or deploy until such data has been removed or moved to an
appropriate untracked local file.
