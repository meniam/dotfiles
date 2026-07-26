#!/usr/bin/env bash
# Install PHP 8.5 from the Sury APT repository on Debian.
set -euo pipefail

. "$DOTFILES_DIR/lib/common.sh"

[ "$OS" = "linux" ] || exit 0

[ -r /etc/os-release ] || die "Cannot identify the Linux distribution."
# shellcheck disable=SC1091
. /etc/os-release
[ "${ID:-}" = "debian" ] || die "The php85 module supports Debian only (detected: ${ID:-unknown})."

step "Configuring the Sury PHP APT repository" "*"
# shellcheck disable=SC2086
$SUDO apt-get update -y
apt_install lsb-release ca-certificates curl

repository_codename="$(lsb_release -sc)"
[ -n "$repository_codename" ] || die "Cannot identify the Debian release codename."

temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT HUP INT TERM
keyring_package="$temporary_dir/debsuryorg-archive-keyring.deb"
repository_file="$temporary_dir/php.list"

curl -fsSLo "$keyring_package" https://packages.sury.org/debsuryorg-archive-keyring.deb
# shellcheck disable=SC2086
$SUDO dpkg -i "$keyring_package"

printf '%s\n' "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $repository_codename main" >"$repository_file"
# shellcheck disable=SC2086
$SUDO install -m 0644 "$repository_file" /etc/apt/sources.list.d/php.list

step "Installing PHP 8.5 from Sury" "*"
# shellcheck disable=SC2086
$SUDO apt-get update -y
apt_install php8.5
