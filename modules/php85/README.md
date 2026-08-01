# PHP 8.5

PHP 8.5 with the extensions Composer and the common frameworks need, pinned so
an upgrade cannot move it to another minor version.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none
- Linux distribution support: Debian only

## Included tools

| Utility | Purpose |
| --- | --- |
| PHP 8.5 CLI | The interpreter, from [Sury](https://deb.sury.org/) on Debian and from Homebrew on macOS. |
| PHP-FPM | Requested by name on Debian, so the process manager arrives without a web server attached. |
| Bundled extensions | `opcache`, `mbstring`, `intl`, `curl`, `gd`, `bcmath`, `zip`, `xml`, `pgsql`. |
| PECL extensions | `mongodb`, `redis`, `memcached`, `igbinary`, `amqp`, `ssh2`, `apcu` — Debian only. |
| [Composer](https://getcomposer.org/) | Dependency manager, installed from the official installer into `~/.local/bin`. |

`ctype`, `fileinfo`, `ftp`, `iconv`, `phar`, `posix`, `sockets`, `tokenizer`,
and `sodium` come with `php8.5-common`, and `pcntl` with `php8.5-cli`, so none
of them is listed separately.

## Keeping the version pinned

Both platforms can quietly hand over a different interpreter, and each is
avoided differently.

**Debian.** Package names carry the version — `php8.5-cli`, `php8.5-mbstring`
and so on — so APT either installs 8.5 or fails with no candidate. It cannot
fall back to 8.4.

The `php8.5` metapackage is **not** used, even though it is version-correct. It
depends on `libapache2-mod-php8.5 | php8.5-fpm | php8.5-cgi`, APT satisfies the
first alternative, and Apache arrives on a machine that never asked for a web
server. Install `php8.5-fpm` explicitly if a web stack is actually wanted.

**macOS — 8.5 cannot be pinned yet.** homebrew-core publishes the current
release as the unversioned `php`, and `php@8.5` is merely an *alias* of it:

```
$ brew info --formula php@8.5 --json=v2
name: php | full_name: php | aliases: ['php@8.5']
```

A real, keg-only `php@8.5` appears only when 8.6 ships — exactly how `php@8.4`
looks today. Until then `brew upgrade` can move the installed formula to 8.6,
and nothing in Homebrew prevents it. The `shivammathur/php` tap does not help
either: it carries `php@8.4` and `php@8.6`, but not the release that core
currently owns.

So the module detects instead of pretending. `setup.sh` asks for `php@8.5`,
falls back to whatever the alias resolves to, and then **verifies the reported
version**; the probe repeats that check. A drift to 8.6 turns the module red
rather than passing silently, and reinstalling it picks up the versioned
formula that will exist by then.

Composer is not taken from Homebrew for a related reason — its formula depends
on the unversioned `php` and would put a second interpreter on the machine.

`config/.config/zsh/import/25-php.zsh` puts `/opt/homebrew/opt/php@8.5/bin` at
the front of `PATH`, the same treatment `20-path.zsh` gives the other keg-only
formulas, so `php` keeps resolving to 8.5 after it becomes keg-only. `setup.sh`
and the probe do not rely on it: both go through `brew --prefix`.

## Composer

`setup.sh` downloads `getcomposer.org/installer`, reads the SHA-384 upstream
publishes at `composer.github.io/installer.sig`, and compares them with
`hash_file()` before running the installer. A mismatch aborts the module. The
result is a single `composer` in `~/.local/bin`, running on the pinned 8.5.

## Installation behavior

On Debian, `setup.sh`:

1. verifies that `/etc/os-release` identifies Debian;
2. installs `lsb-release`, CA certificates, and curl;
3. downloads and installs Sury's archive-keyring package;
4. writes `/etc/apt/sources.list.d/php.list` for the detected codename;
5. refreshes APT metadata; and
6. installs `php8.5-cli`, `php8.5-fpm`, and the extension set.

On macOS `setup.sh` resolves the formula name itself and installs it, because
the choice between `php@8.5` and its alias depends on what upstream currently
publishes. The PECL extensions are Debian-only: on macOS they would each need a
`pecl install` and a compiler run, so they are left out and the probe does not
ask for them there.

Both paths then verify that the interpreter reports `PHP 8.5.x` and install
Composer.

This module modifies system APT configuration on Debian and requires network
and `sudo` access when it is not run as root. Ubuntu is rejected: the same
maintainer publishes `ppa:ondrej/php` for it, which this module does not
configure. Application-specific PHP configuration — `php.ini` tuning, FPM pools,
per-project settings — is out of scope.

The probe resolves the interpreter per platform, requires it to report
`PHP 8.5.x`, checks `mbstring` as a stand-in for the bundled extensions, and
requires `composer` on `PATH`. On Debian it additionally checks `redis` and
`pgsql` for the PECL set and `php-fpm8.5` for the process manager.
