# Node.js 24

Node.js 24 and npm for macOS, Debian, and Ubuntu.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none

## macOS installation

Homebrew installs the versioned `node@24` formula. `setup.sh` then runs
`brew link --overwrite --force node@24` when `node` is not already version 24,
making the versioned formula active on `PATH`. This can replace links created
by another Homebrew Node.js formula.

## Debian and Ubuntu installation

The APT manifest supplies curl, GnuPG, and CA certificates. When Node.js 24 is
not already active, `setup.sh`:

1. verifies that `/etc/os-release` identifies Debian or Ubuntu;
2. installs the NodeSource signing key at `/etc/apt/keyrings/nodesource.gpg`;
3. writes the NodeSource 24 repository to
   `/etc/apt/sources.list.d/nodesource-node24.list`;
4. selects the first available `24.x` package version; and
5. installs that exact `nodejs` version with downgrades allowed.

The exact-version install keeps the major version deterministic but may replace
a newer system Node.js package. The module does not install global npm packages
or application-specific Node.js configuration.

The probe requires `node --version` to begin with `v24.` and also requires a
working `npm` command.
