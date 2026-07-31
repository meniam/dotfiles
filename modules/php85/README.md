# PHP 8.5

PHP 8.5 from the Sury package repository for Debian.

- Platforms: Linux
- Default: off
- Dependencies: none
- Linux distribution support: Debian only

## Installation behavior

`setup.sh`:

1. verifies that `/etc/os-release` identifies Debian;
2. installs `lsb-release`, CA certificates, and curl;
3. downloads and installs Sury's archive-keyring package;
4. writes `/etc/apt/sources.list.d/php.list` for the detected Debian codename;
5. refreshes APT metadata; and
6. installs the `php8.5` package.

This module modifies system APT configuration and requires network and `sudo`
access when it is not run as root. It does not install additional PHP 8.5
extensions, Composer, PECL packages, or application-specific PHP configuration.

The probe requires the `php8.5` executable to report a `PHP 8.5.x` version. The
unversioned `php` command is not changed or checked explicitly.
