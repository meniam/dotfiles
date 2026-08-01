#!/usr/bin/env bash
# Install uv, a uv-managed CPython interpreter, and the uv-managed Python tools.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"

uv_bin="$(command -v uv 2>/dev/null || true)"

if [ -z "$uv_bin" ]; then
  installer="$(mktemp)"
  trap 'rm -f "$installer"' EXIT HUP INT TERM
  step "Downloading the uv installer" "*"
  curl --proto '=https' --tlsv1.2 -fsSL --connect-timeout 15 --retry 2 \
    "https://astral.sh/uv/install.sh" -o "$installer" || die "Unable to download uv."
  step "Installing uv into ~/.local/bin" "*"
  # The zsh module owns PATH, so the installer must not edit shell startup files.
  UV_INSTALL_DIR="$HOME/.local/bin" INSTALLER_NO_MODIFY_PATH=1 sh "$installer" \
    || die "The uv installation failed."
  uv_bin="$HOME/.local/bin/uv"
fi

[ -x "$uv_bin" ] || die "uv was not installed."
command -v uvx >/dev/null 2>&1 || die "uvx was not installed next to uv."

# The stowed uv.toml asks for managed interpreters only, so an interpreter has to
# exist before any tool environment or project environment can be created.
if ! "$uv_bin" python list --only-installed --managed-python 2>/dev/null | grep -q .; then
  step "Installing a uv-managed CPython interpreter" "*"
  "$uv_bin" python install || die "uv could not install a managed CPython interpreter."
fi

# Ruff and ty live in their own uv tool environments and are linked into
# ~/.local/bin. The list check keeps a repeated run offline.
for python_tool in ruff ty; do
  if ! "$uv_bin" tool list 2>/dev/null | grep -q "^$python_tool v"; then
    step "Installing $python_tool as a uv tool" "*"
    "$uv_bin" tool install "$python_tool" || die "uv could not install $python_tool."
  fi
done

command -v ruff >/dev/null 2>&1 || die "ruff is not available on PATH after installation."
command -v ty >/dev/null 2>&1 || die "ty is not available on PATH after installation."

step "Python toolchain: $("$uv_bin" --version)" "*"
step "Restart your shell if ~/.local/bin is not already on PATH." "*"
