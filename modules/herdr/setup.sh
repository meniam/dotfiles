#!/usr/bin/env bash
# herdr module: agent multiplexer (https://github.com/ogulcancelik/herdr).
# macOS installs it via packages.brew. Linux uses the official
# herdr.dev/install.sh script, wrapped in a timeout so a stalled
# network or site does not hang the installer indefinitely.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"
detect_os

export PATH="$HOME/.local/bin:$HOME/.herdr/bin:$PATH"

if command -v herdr >/dev/null 2>&1; then
  step "herdr already installed: $(herdr --version 2>/dev/null || echo '?')" "✓"
  exit 0
fi

if [ "$OS" != "linux" ]; then
  warn "herdr not found — on macOS it is installed via packages.brew."
  exit 0
fi

step "Installing herdr (herdr.dev/install.sh, up to 5 min — downloads a binary)…" "*"
rc=0
with_timeout 300 sh -c 'curl -fsSL --connect-timeout 15 --retry 2 https://herdr.dev/install.sh | sh' || rc=$?

hash -r 2>/dev/null || true
if command -v herdr >/dev/null 2>&1; then
  step "herdr installed: $(herdr --version 2>/dev/null || echo ok)" "*"
  exit 0
fi

# Installation failed — report why but do not fail the rest of the install (herdr is optional).
if [ "$rc" -eq 124 ]; then
  warn "herdr: 5-minute timeout (herdr.dev/network unreachable) — skipping."
elif [ "$rc" -ne 0 ]; then
  warn "herdr: installer exited with an error (code $rc) — skipping."
else
  warn "herdr: installer ran, but the binary is not on PATH — it should appear after a new login."
fi
warn "Install it later manually:  curl -fsSL https://herdr.dev/install.sh | sh"
exit 0
