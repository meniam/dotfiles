#!/usr/bin/env bash
# Install PHP 8.5 — from Sury on Debian, from the pinned Homebrew formula on
# macOS — and Composer from its official installer.
set -euo pipefail

. "$DOTFILES_DIR/lib/common.sh"

php_bin=""

if [ "$OS" = "linux" ]; then
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

  curl -fsSL --connect-timeout 15 --retry 2 \
    -o "$keyring_package" https://packages.sury.org/debsuryorg-archive-keyring.deb \
    || die "Unable to download the Sury archive keyring."
  # shellcheck disable=SC2086
  $SUDO dpkg -i "$keyring_package"

  printf '%s\n' "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $repository_codename main" >"$repository_file"
  # shellcheck disable=SC2086
  $SUDO install -m 0644 "$repository_file" /etc/apt/sources.list.d/php.list

  step "Installing PHP 8.5 from Sury" "*"
  # shellcheck disable=SC2086
  $SUDO apt-get update -y

  # Individual packages rather than the php8.5 metapackage. That metapackage
  # depends on `libapache2-mod-php8.5 | php8.5-fpm | php8.5-cgi`, and APT
  # satisfies the first alternative, so it drags Apache onto a machine that
  # never asked for a web server; php8.5-fpm is requested here by name instead.
  # Every name carries the version, so APT can only install 8.5 or fail
  # outright — it cannot fall back to 8.4.
  #
  # ctype, fileinfo, ftp, iconv, phar, posix, sockets, tokenizer, and sodium
  # come with php8.5-common, and pcntl with php8.5-cli, so none of them need an
  # entry of their own.
  apt_install \
    php8.5-cli \
    php8.5-fpm \
    php8.5-common \
    php8.5-opcache \
    php8.5-mbstring \
    php8.5-intl \
    php8.5-curl \
    php8.5-gd \
    php8.5-bcmath \
    php8.5-zip \
    php8.5-xml \
    php8.5-pgsql \
    php8.5-mongodb \
    php8.5-redis \
    php8.5-memcached \
    php8.5-igbinary \
    php8.5-amqp \
    php8.5-ssh2 \
    php8.5-apcu

  php_bin="$(command -v php8.5 2>/dev/null || true)"
else
  # Homebrew has no way to pin 8.5 while it is the current release: php@8.5 is
  # an alias of the unversioned php formula, and homebrew-core only publishes a
  # real, keg-only php@8.5 once 8.6 ships — which is exactly how php@8.4 looks
  # today. Ask for the versioned name and fall back to the alias target, so the
  # same script keeps working across that transition. The version check below
  # catches the drift either way.
  php_formula="php@8.5"
  if brew info --formula php@8.5 2>/dev/null | head -1 | grep -q '^==> php:'; then
    php_formula="php"
  fi
  step "Installing PHP 8.5 from the $php_formula formula" "*"
  brew_install "$php_formula" || die "Homebrew could not install $php_formula."

  # Resolve through the formula's own prefix rather than through PATH: once the
  # formula is keg-only, `php` on PATH may be a different interpreter.
  php_prefix="$(brew --prefix "$php_formula" 2>/dev/null || true)"
  [ -n "$php_prefix" ] || die "Homebrew does not report a prefix for $php_formula."
  php_bin="$php_prefix/bin/php"
fi

{ [ -n "$php_bin" ] && [ -x "$php_bin" ]; } || die "PHP 8.5 was not installed."
"$php_bin" --version 2>/dev/null | grep -q "^PHP 8\.5\." \
  || die "Expected PHP 8.5, found: $("$php_bin" --version 2>/dev/null | head -1)"

# Composer from its official installer, verified against the SHA-384 upstream
# publishes for it. Homebrew's composer formula is not used because it depends
# on the unversioned php formula and would install a second interpreter.
if ! command -v composer >/dev/null 2>&1; then
  step "Installing Composer" "*"
  composer_dir="$(mktemp -d)"
  trap 'rm -rf "${temporary_dir:-}" "$composer_dir"' EXIT HUP INT TERM
  composer_setup="$composer_dir/composer-setup.php"

  expected_checksum="$(curl -fsSL --connect-timeout 15 --retry 2 \
    https://composer.github.io/installer.sig)" \
    || die "Unable to download the Composer installer signature."
  curl -fsSL --connect-timeout 15 --retry 2 \
    -o "$composer_setup" https://getcomposer.org/installer \
    || die "Unable to download the Composer installer."

  actual_checksum="$("$php_bin" -r "echo hash_file('sha384', '$composer_setup');")"
  [ "$expected_checksum" = "$actual_checksum" ] \
    || die "The Composer installer checksum does not match the published signature."

  mkdir -p "$HOME/.local/bin"
  "$php_bin" "$composer_setup" --quiet --install-dir="$HOME/.local/bin" --filename=composer \
    || die "The Composer installation failed."
fi

step "PHP toolchain: $("$php_bin" --version | head -1)" "*"
if [ "$OS" = "mac" ]; then
  step "php resolves through ~/.config/zsh/25-php.zsh; restart your shell." "*"
fi
