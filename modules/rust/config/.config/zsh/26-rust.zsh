# Put rustup's shims and the cargo-installed binaries on PATH.
#
# rustup-init is run with --no-modify-path, so it writes nothing into ~/.zshenv,
# ~/.profile, or ~/.bashrc. PATH belongs to the zsh module, and ~/.cargo/env in
# ~/.zshenv would also be sourced by every non-interactive zsh.
#
# This fragment belongs to the `rust` module: .zshrc sources every numbered file
# in this directory, so a machine without the module never has it.
if [[ -d "${CARGO_HOME:-$HOME/.cargo}/bin" ]]; then
  path=("${CARGO_HOME:-$HOME/.cargo}/bin" $path)
  export PATH
fi
