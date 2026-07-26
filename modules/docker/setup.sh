#!/usr/bin/env bash
# Install Docker Engine/Desktop and Docker terminal interfaces.
set -euo pipefail

. "$DOTFILES_DIR/lib/common.sh"
detect_os

repository_file=""
lazydocker_installer=""
oxker_dir=""

cleanup() {
  [ -z "$repository_file" ] || rm -f "$repository_file"
  [ -z "$lazydocker_installer" ] || rm -f "$lazydocker_installer"
  [ -z "$oxker_dir" ] || rm -rf "$oxker_dir"
}
trap cleanup EXIT HUP INT TERM

install_docker_engine() {
  [ "$OS" = "linux" ] || return 0

  [ -r /etc/os-release ] || die "Cannot identify the Linux distribution."
  # shellcheck disable=SC1091
  . /etc/os-release
  [ "${ID:-}" = "debian" ] || die "The docker module supports Debian only on Linux (detected: ${ID:-unknown})."
  [ -n "${VERSION_CODENAME:-}" ] || die "Cannot identify the Debian release codename."

  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    log "Docker Engine is already installed."
    return 0
  fi

  conflicting_packages=""
  for package in docker.io docker-compose docker-doc podman-docker containerd runc; do
    if dpkg-query -W -f='${db:Status-Abbrev}' "$package" 2>/dev/null | grep -q '^ii '; then
      conflicting_packages="$conflicting_packages $package"
    fi
  done

  [ -z "$conflicting_packages" ] || die "Remove conflicting packages before installing Docker Engine:$conflicting_packages"

  step "Configuring the official Docker apt repository" "*"
  # shellcheck disable=SC2086
  $SUDO apt-get update -y
  apt_install ca-certificates curl
  # shellcheck disable=SC2086
  $SUDO install -m 0755 -d /etc/apt/keyrings
  # shellcheck disable=SC2086
  $SUDO curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  # shellcheck disable=SC2086
  $SUDO chmod a+r /etc/apt/keyrings/docker.asc

  repository_file="$(mktemp)"
  cat >"$repository_file" <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $VERSION_CODENAME
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
  # shellcheck disable=SC2086
  $SUDO install -m 0644 "$repository_file" /etc/apt/sources.list.d/docker.sources
  rm -f "$repository_file"
  repository_file=""

  step "Installing Docker Engine" "*"
  # shellcheck disable=SC2086
  $SUDO apt-get update -y
  apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_oxker() {
  if command -v oxker >/dev/null 2>&1; then
    log "Oxker is already installed: $(oxker --version 2>/dev/null || echo '?')"
    return 0
  fi

  if [ "$OS" = "mac" ]; then
    warn "Oxker was not found after Homebrew package installation."
    return 0
  fi

  case "$(uname -m)" in
    x86_64|amd64) architecture="x86_64" ;;
    aarch64|arm64) architecture="arm64" ;;
    *) die "Unsupported architecture for Oxker: $(uname -m)" ;;
  esac

  oxker_dir="$(mktemp -d)"
  archive="$oxker_dir/oxker.tar.gz"
  url="https://github.com/mrjackwills/oxker/releases/latest/download/oxker_linux_${architecture}.tar.gz"
  step "Downloading Oxker ($architecture)" "*"
  curl -fL --connect-timeout 15 --retry 2 "$url" -o "$archive" || die "Unable to download Oxker."
  tar -xzf "$archive" -C "$oxker_dir" oxker
  mkdir -p "$HOME/.local/bin"
  install -Dm755 "$oxker_dir/oxker" "$HOME/.local/bin/oxker"
  rm -rf "$oxker_dir"
  oxker_dir=""
}

install_lazydocker() {
  command -v lazydocker >/dev/null 2>&1 && return 0

  if [ "$OS" = "mac" ]; then
    warn "LazyDocker was not found after Homebrew package installation."
    return 0
  fi

  lazydocker_installer="$(mktemp)"
  step "Downloading the LazyDocker installer" "*"
  curl -fsSL --connect-timeout 15 --retry 2 \
    "https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh" \
    -o "$lazydocker_installer" || die "Unable to download LazyDocker."
  step "Installing LazyDocker to ~/.local/bin" "*"
  DIR="$HOME/.local/bin" bash "$lazydocker_installer"
  rm -f "$lazydocker_installer"
  lazydocker_installer=""
}

install_docker_engine
install_oxker
install_lazydocker
