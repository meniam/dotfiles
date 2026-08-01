#!/usr/bin/env bash
# Install the current Neovim release on Linux and synchronize NvChad plugins.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"
detect_os

download_file() {
  curl -fL --connect-timeout 15 --retry 2 "$1" -o "$2"
}

if [ "$OS" = "linux" ]; then
  # Official Linux releases require glibc 2.34 or later.
  if ! glibc_at_least 2 34; then
    warn "Skipping Neovim: glibc >= 2.34 is required (found: $(glibc_version 2>/dev/null || echo '?'))."
    warn "Upgrade the OS or build Neovim from source, then rerun this module."
    exit 0
  fi

  case "$(uname -m)" in
    x86_64|amd64) archive_name="nvim-linux-x86_64.tar.gz" ;;
    aarch64|arm64) archive_name="nvim-linux-arm64.tar.gz" ;;
    *) die "Unsupported architecture for Neovim: $(uname -m)" ;;
  esac

  temporary_dir="$(mktemp -d)"
  archive="$temporary_dir/nvim.tar.gz"
  step "Downloading Neovim ($archive_name)" "*"
  if ! download_file "https://github.com/neovim/neovim/releases/latest/download/$archive_name" "$archive"; then
    rm -rf "$temporary_dir"
    die "Unable to download Neovim."
  fi

  # Replace only the dedicated Neovim installation directory after a successful download.
  $SUDO rm -rf /opt/nvim
  $SUDO mkdir -p /opt/nvim
  $SUDO tar -xzf "$archive" -C /opt/nvim --strip-components=1
  $SUDO ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm -rf "$temporary_dir"

  if ! command -v stylua >/dev/null 2>&1; then
    case "$(uname -m)" in
      x86_64|amd64) stylua_arch="linux-x86_64" ;;
      aarch64|arm64) stylua_arch="linux-aarch64" ;;
      *) stylua_arch="" ;;
    esac
    if [ -n "$stylua_arch" ]; then
      temporary_dir="$(mktemp -d)"
      archive="$temporary_dir/stylua.zip"
      if download_file "https://github.com/JohnnyMorganz/StyLua/releases/latest/download/stylua-$stylua_arch.zip" "$archive"; then
        unzip -q "$archive" -d "$temporary_dir"
        $SUDO install -m755 "$temporary_dir/stylua" /usr/local/bin/stylua
      else
        warn "StyLua could not be installed; Lua formatting will be unavailable."
      fi
      rm -rf "$temporary_dir"
    fi
  fi

  # Debian packages the fd executable as fdfind.
  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    $SUDO ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi
fi

NVIM_BIN="$(command -v nvim || true)"
if [ -z "$NVIM_BIN" ]; then
  warn "Neovim is unavailable; plugin synchronization is skipped."
  exit 0
fi
log "Neovim: $($NVIM_BIN --version | head -1)"

if command -v npm >/dev/null 2>&1; then
  step "Installing optional language servers" "*"
  npm_sudo=""
  [ "$OS" = "linux" ] && npm_sudo="$SUDO"
  # shellcheck disable=SC2086
  $npm_sudo npm install -g vscode-langservers-extracted @tailwindcss/language-server intelephense >/dev/null 2>&1 \
    || warn "Optional language servers could not be installed."
fi

if command -v php >/dev/null 2>&1; then
  step "Installing php-cs-fixer" "*"
  mkdir -p "$HOME/.local/bin"
  if download_file "https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/releases/latest/download/php-cs-fixer.phar" "$HOME/.local/bin/php-cs-fixer"; then
    chmod +x "$HOME/.local/bin/php-cs-fixer"
  else
    warn "php-cs-fixer could not be installed."
  fi
fi

step "Synchronizing Neovim plugins" "*"
with_timeout 300 "$NVIM_BIN" --headless "+Lazy! sync" +qa 2>/dev/null \
  || warn "Plugin synchronization did not finish; plugins will be installed on the next Neovim launch."
step "Tree-sitter parsers will be installed on the first Neovim launch." "*"
