#!/usr/bin/env bash
# Install mise from Homebrew or the upstream APT repository, then make sure the
# global configuration file exists before mise is used.
set -euo pipefail

. "$DOTFILES_DIR/lib/common.sh"
detect_os

mise_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/mise"

# `mise use -g`, `mise set -g`, and `mise settings set` write to the lowest
# precedence file in the highest precedence directory. Inside ~/.config/mise
# that is the stowed conf.d fragment whenever config.toml is missing, and the
# fragment is a symlink into this repository, so a global tool version would be
# written straight into the tracked tree. An empty config.toml takes the writes.
ensure_global_config() {
  [ -n "${HOME:-}" ] || die "HOME is not set; refusing to create the mise configuration."
  mkdir -p "$mise_config_dir"
  [ -e "$mise_config_dir/config.toml" ] && return 0
  step "Creating $mise_config_dir/config.toml for global writes" "*"
  : >"$mise_config_dir/config.toml"
}

if [ "$OS" = "mac" ]; then
  command -v mise >/dev/null 2>&1 || die "mise is not on PATH after the Homebrew installation."
  ensure_global_config
  step "mise: $(mise --version)" "*"
  exit 0
fi

[ -r /etc/os-release ] || die "Cannot identify the Linux distribution."
# shellcheck disable=SC1091
. /etc/os-release
case "${ID:-}" in
  debian|ubuntu) ;;
  *) die "The mise module supports Debian and Ubuntu only (detected: ${ID:-unknown})." ;;
esac

if ! command -v mise >/dev/null 2>&1; then
  # The upstream repository publishes these two architectures only. Adding it on
  # anything else produces an APT source that can never resolve a candidate.
  architecture="$(dpkg --print-architecture)"
  case "$architecture" in
    amd64|arm64) ;;
    *) die "The mise APT repository publishes amd64 and arm64 only (detected: $architecture). Install mise from https://mise.run instead." ;;
  esac

  keyring_dir="/etc/apt/keyrings"
  keyring_file="$keyring_dir/mise.gpg"
  repository_file="/etc/apt/sources.list.d/mise.list"
  temporary_dir="$(mktemp -d)"
  trap 'rm -rf "$temporary_dir"' EXIT HUP INT TERM

  step "Configuring the mise APT repository" "*"
  # shellcheck disable=SC2086
  $SUDO install -m 0755 -d "$keyring_dir"
  curl -fsSL --connect-timeout 15 --retry 2 \
    "https://mise.jdx.dev/gpg-key.pub" \
    -o "$temporary_dir/mise.key" || die "Unable to download the mise signing key."
  gpg --dearmor --yes -o "$temporary_dir/mise.gpg" "$temporary_dir/mise.key"
  # shellcheck disable=SC2086
  $SUDO install -m 0644 "$temporary_dir/mise.gpg" "$keyring_file"
  printf '%s\n' \
    "deb [signed-by=$keyring_file arch=$architecture] https://mise.jdx.dev/deb stable main" \
    >"$temporary_dir/mise.list"
  # shellcheck disable=SC2086
  $SUDO install -m 0644 "$temporary_dir/mise.list" "$repository_file"

  # shellcheck disable=SC2086
  $SUDO apt-get update -y
  step "Installing mise" "*"
  apt_install mise

  command -v mise >/dev/null 2>&1 || die "mise is not on PATH after the APT installation."
fi

ensure_global_config
step "mise: $(mise --version)" "*"
