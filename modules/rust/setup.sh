#!/usr/bin/env bash
# Install the minimal stable Rust toolchain with rustup.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"

cargo_home="$HOME/.cargo"
rustup_bin="$cargo_home/bin/rustup"
cargo_bin="$cargo_home/bin/cargo"
rustc_bin="$cargo_home/bin/rustc"

if [ ! -x "$rustup_bin" ]; then
  installer="$(mktemp)"
  trap 'rm -f "$installer"' EXIT HUP INT TERM
  step "Downloading the Rustup installer" "*"
  curl --proto '=https' --tlsv1.2 -fsSL --connect-timeout 15 --retry 2 \
    "https://sh.rustup.rs" -o "$installer" || die "Unable to download Rustup."
  step "Installing the minimal stable Rust toolchain" "*"
  sh "$installer" -y --profile minimal || die "Rustup installation failed."
fi

if [ ! -x "$cargo_bin" ] || [ ! -x "$rustc_bin" ]; then
  step "Installing the stable Rust toolchain" "*"
  "$rustup_bin" toolchain install stable --profile minimal
  "$rustup_bin" default stable
fi

[ -x "$rustup_bin" ] || die "Rustup was not installed."
[ -x "$cargo_bin" ] || die "Cargo was not installed."
[ -x "$rustc_bin" ] || die "Rustc was not installed."

step "Rust toolchain: $($rustc_bin --version)" "*"
step "Restart your shell or source ~/.cargo/env to use cargo and rustc." "*"
