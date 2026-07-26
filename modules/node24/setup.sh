#!/usr/bin/env bash
# Install Node.js 24 from Homebrew or the official NodeSource APT repository.
set -euo pipefail

. "$DOTFILES_DIR/lib/common.sh"
detect_os

node_is_24() {
  command -v node >/dev/null 2>&1 && node --version 2>/dev/null | grep -q '^v24\.'
}

if [ "$OS" = "mac" ]; then
  if ! node_is_24; then
    step "Activating Node.js 24 with Homebrew" "*"
    brew link --overwrite --force node@24
  fi
  node_is_24 || die "Node.js 24 is not available on PATH after Homebrew installation."
  exit 0
fi

[ -r /etc/os-release ] || die "Cannot identify the Linux distribution."
# shellcheck disable=SC1091
. /etc/os-release
case "${ID:-}" in
  debian|ubuntu) ;;
  *) die "The node24 module supports Debian and Ubuntu only (detected: ${ID:-unknown})." ;;
esac

if node_is_24; then
  exit 0
fi

keyring_dir="/etc/apt/keyrings"
keyring_file="$keyring_dir/nodesource.gpg"
repository_file="/etc/apt/sources.list.d/nodesource-node24.list"
temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT HUP INT TERM

step "Configuring the NodeSource Node.js 24 repository" "*"
# shellcheck disable=SC2086
$SUDO install -m 0755 -d "$keyring_dir"
curl -fsSL --connect-timeout 15 --retry 2 \
  "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" \
  -o "$temporary_dir/nodesource.key" || die "Unable to download the NodeSource signing key."
gpg --dearmor --yes -o "$temporary_dir/nodesource.gpg" "$temporary_dir/nodesource.key"
# shellcheck disable=SC2086
$SUDO install -m 0644 "$temporary_dir/nodesource.gpg" "$keyring_file"
printf '%s\n' \
  "deb [signed-by=$keyring_file] https://deb.nodesource.com/node_24.x nodistro main" \
  >"$temporary_dir/nodesource-node24.list"
# shellcheck disable=SC2086
$SUDO install -m 0644 "$temporary_dir/nodesource-node24.list" "$repository_file"

# shellcheck disable=SC2086
$SUDO apt-get update -y
node_package_version="$(apt-cache madison nodejs | awk '$3 ~ /^24\./ { print $3; exit }')"
[ -n "$node_package_version" ] || die "NodeSource did not provide a Node.js 24 package for this architecture."
step "Installing Node.js $node_package_version" "*"
# shellcheck disable=SC2086
$SUDO apt-get install -y --no-install-recommends --allow-downgrades "nodejs=$node_package_version"

node_is_24 || die "Node.js 24 is not available on PATH after installation."
