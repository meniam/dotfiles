# Linux

Debian/Ubuntu system prerequisites used by the command-line modules and remote
terminal sessions.

- Platforms: Linux
- Default: on
- Dependencies: `must-have`

## Included packages

| Package | Purpose |
| --- | --- |
| `locales` | Supplies locale generation and locale data. |
| `lsb-release` | Reports distribution and codename information used by repository setup scripts. |
| `apt-transport-https`, `apt-utils` | Supplies APT transport compatibility and package-management utilities. |
| `openssl` | Provides TLS and cryptographic command-line operations. |
| `gnupg2`, `gpg` | Verifies repository keys and signed artifacts. |
| `pkg-config` | Exposes compiler and linker flags for installed libraries. |
| `build-essential` | Installs the compiler, Make, and baseline native build tools. |
| `sudo` | Allows privileged installation from non-root accounts. |
| `kitty-terminfo` | Lets remote systems understand Kitty terminal capabilities. |
| `pydf` | Displays colourized filesystem usage. |

The module has no Stow payload or setup script. Installation is entirely driven
by `packages.apt`; the shared installer skips packages for which the configured
APT sources have no candidate.

The probe checks the principal commands, compiler and Make availability, the
system certificate updater, and the `xterm-kitty` terminfo entry. A skipped
package can therefore leave the module installed only partially and visible as
incomplete in `./install --status`.
