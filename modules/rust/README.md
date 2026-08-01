# Rust

The stable Rust toolchain through rustup, with the components and cargo tools a
Rust project normally needs.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none

## Included tools

| Utility | Purpose |
| --- | --- |
| [rustup](https://rustup.rs/) | Installs and switches toolchains, targets, and components. |
| Cargo and rustc | The build tool and the compiler, from the stable toolchain. |
| [Clippy](https://doc.rust-lang.org/clippy/) | Lints beyond what the compiler reports. |
| [rustfmt](https://github.com/rust-lang/rustfmt) | Formats source to the standard style. |
| [rust-analyzer](https://rust-analyzer.github.io/) | LSP server; this is what the `nvim` module talks to. |
| [cargo-binstall](https://github.com/cargo-bins/cargo-binstall) | Installs cargo tools from prebuilt releases instead of building them. |
| [cargo-nextest](https://nexte.st/) | Test runner with parallel execution and readable output. |
| [cargo-audit](https://github.com/rustsec/rustsec) | Reports known vulnerabilities in a dependency tree. |
| [cargo-edit](https://github.com/killercup/cargo-edit) | `cargo add`, `rm`, `upgrade`, `set-version` for editing `Cargo.toml`. |
| [sccache](https://github.com/mozilla/sccache) | Shares a compilation cache between projects and rebuilds. |

`clippy`, `rustfmt`, and `rust-analyzer` are added as rustup *components* rather
than as separate packages, so they are updated together with the toolchain they
belong to.

## PATH

rustup is run with `--no-modify-path`. Left to itself it appends
`. "$HOME/.cargo/env"` to `~/.zshenv`, `~/.profile`, `~/.bashrc`, and
`~/.bash_profile` — four files this repository does not own, and the `~/.zshenv`
entry is sourced by every non-interactive zsh as well.

`config/.config/zsh/26-rust.zsh` puts `~/.cargo/bin` on `PATH` instead,
the same way the `ssh` and `php85` modules ship their own fragments. `.zshrc`
sources every numbered file in that directory, so a machine without this module
never has it. For any other shell, source `~/.cargo/env` from a machine-local
rc file.

## Installation behavior

When `~/.cargo/bin/rustup` is absent, `setup.sh` downloads the official rustup
installer over TLS and runs it non-interactively with the minimal profile. The
components above are then added individually, which is cheaper than the
`default` profile and skips the offline documentation.

cargo tools are installed with `cargo-binstall`, which downloads the release
binary each project publishes. Building `sccache` or `cargo-audit` from source
takes minutes; fetching them takes seconds. cargo-binstall itself comes from its
own release script.

A component or tool that fails to install is a warning, not a module failure —
losing one should not discard a working toolchain. Repeated runs are offline: an
existing toolchain, component, and tool are detected and skipped.

The module installs into rustup's standard user locations under `~/.cargo` and
`~/.rustup`. It uses no Homebrew or APT manifest and does not select a dated or
nightly toolchain.

The probe prepends `~/.cargo/bin` to `PATH`, then *runs* `rustc` and `cargo`
rather than only checking that the files exist — a half-installed toolchain
leaves the files in place but cannot report a version. It also requires the
three components and all five cargo tools.
