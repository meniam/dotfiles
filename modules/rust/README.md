# Rust

The stable Rust toolchain installed through rustup.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none

## Installation behavior

When `~/.cargo/bin/rustup` is absent, `setup.sh` downloads the official rustup
installer over TLS and runs it non-interactively with the minimal profile. If
rustup exists but Cargo or rustc is missing, the script installs and selects the
stable toolchain with the same minimal profile.

The module installs into rustup's standard user locations under `~/.cargo` and
`~/.rustup`. It does not use Homebrew or APT package manifests, install extra
components such as Clippy or rustfmt explicitly, or select a dated toolchain.

The probe requires executable `rustup`, `cargo`, and `rustc` files under
`~/.cargo/bin`. Restart the shell or source `~/.cargo/env` after the first
installation if that directory is not already on `PATH`.
