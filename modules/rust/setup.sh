#!/usr/bin/env bash
# Install the stable Rust toolchain with rustup, its development components,
# and the cargo tools that ship as prebuilt binaries.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"

cargo_home="${CARGO_HOME:-$HOME/.cargo}"
rustup_bin="$cargo_home/bin/rustup"
cargo_bin="$cargo_home/bin/cargo"
rustc_bin="$cargo_home/bin/rustc"
installer=""
binstall_installer=""
trap 'rm -f "$installer" "$binstall_installer"' EXIT HUP INT TERM

if [ ! -x "$rustup_bin" ]; then
  installer="$(mktemp)"
  step "Downloading the Rustup installer" "*"
  curl --proto '=https' --tlsv1.2 -fsSL --connect-timeout 15 --retry 2 \
    "https://sh.rustup.rs" -o "$installer" || die "Unable to download Rustup."

  # --no-modify-path: rustup would otherwise append `. "$HOME/.cargo/env"` to
  # ~/.zshenv, ~/.profile, ~/.bashrc, and ~/.bash_profile. PATH belongs to the
  # zsh module, and the ~/.zshenv entry would also run for every
  # non-interactive zsh. The stowed 26-rust.zsh fragment adds the directory.
  step "Installing the stable Rust toolchain" "*"
  sh "$installer" -y --profile minimal --no-modify-path \
    || die "Rustup installation failed."
fi

[ -x "$rustup_bin" ] || die "Rustup was not installed."
[ -x "$cargo_bin" ] || die "Cargo was not installed."
[ -x "$rustc_bin" ] || die "Rustc was not installed."

# The minimal profile leaves these out. clippy and rustfmt lint and format, and
# rust-analyzer is the LSP server the nvim module talks to; the rustup component
# follows the toolchain, unlike a separately packaged build of it.
for rust_component in clippy rustfmt rust-analyzer; do
  if ! "$rustup_bin" component list --installed 2>/dev/null | grep -q "^$rust_component"; then
    step "Adding the $rust_component component" "*"
    "$rustup_bin" component add "$rust_component" \
      || warn "rustup could not add the $rust_component component."
  fi
done

# cargo-binstall fetches prebuilt release binaries instead of compiling every
# tool from source, which turns minutes of build time into a download. It comes
# from its own release script for that same reason.
if [ ! -x "$cargo_home/bin/cargo-binstall" ]; then
  binstall_installer="$(mktemp)"
  step "Downloading the cargo-binstall installer" "*"
  curl --proto '=https' --tlsv1.2 -fsSL --connect-timeout 15 --retry 2 \
    "https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh" \
    -o "$binstall_installer" || die "Unable to download the cargo-binstall installer."
  step "Installing cargo-binstall" "*"
  bash "$binstall_installer" || warn "cargo-binstall could not be installed."
fi

# Each entry is <crate>:<binary it provides>. cargo-edit is the odd one out: it
# installs cargo-add, cargo-rm, cargo-set-version, and cargo-upgrade rather than
# a command named after the crate itself.
if [ -x "$cargo_home/bin/cargo-binstall" ]; then
  for cargo_tool in \
    cargo-nextest:cargo-nextest \
    cargo-audit:cargo-audit \
    cargo-edit:cargo-upgrade \
    sccache:sccache; do
    tool_crate="${cargo_tool%%:*}"
    tool_binary="${cargo_tool##*:}"
    [ -x "$cargo_home/bin/$tool_binary" ] && continue
    step "Installing $tool_crate with cargo-binstall" "*"
    "$cargo_home/bin/cargo-binstall" --no-confirm "$tool_crate" \
      || warn "cargo-binstall could not install $tool_crate."
  done
fi

step "Rust toolchain: $("$rustc_bin" --version)" "*"
step "Restart your shell if ~/.cargo/bin is not already on PATH." "*"
