# Neovim

Neovim with an NvChad 2.5 configuration, Lazy-managed plugins, formatting, and
web language-server support.

- Platforms: macOS and Linux
- Default: on
- Dependencies: none

## Packages and installation

On macOS, Homebrew installs Neovim, ripgrep, fd, jq, Node.js, and StyLua.

On Linux, the APT manifest installs the download, build, search, JSON, Node.js,
and npm prerequisites. `setup.sh` then:

- requires glibc 2.34 or later and an x86_64 or arm64 architecture;
- downloads the current official Neovim release;
- replaces `/opt/nvim` and links `/usr/local/bin/nvim` to its executable;
- installs the matching StyLua release into `/usr/local/bin` when possible;
- creates `/usr/local/bin/fd` when Debian exposes fd as `fdfind`;
- installs `vscode-langservers-extracted` and
  `@tailwindcss/language-server` globally through npm; and
- runs `Lazy! sync` headlessly with a five-minute timeout.

StyLua, npm language servers, and plugin synchronization are best-effort steps.
Tree-sitter parsers are installed on the first interactive Neovim launch.

## Configuration

GNU Stow links the configuration to `~/.config/nvim`:

| File | Purpose |
| --- | --- |
| `init.lua` | Bootstraps lazy.nvim and NvChad 2.5, then loads options and mappings. |
| `lua/chadrc.lua` | Selects the OneDark theme and default status line. |
| `lua/configs/lazy.lua` | Configures lazy loading and disables unused built-in runtime plugins. |
| `lua/configs/lspconfig.lua` | Enables HTML, CSS, JSON, and Tailwind CSS language servers. |
| `lua/configs/conform.lua` | Formats Lua with StyLua and web/document formats with Prettier on save. |
| `lua/plugins/init.lua` | Enables Conform and nvim-lspconfig. |
| `lua/mappings.lua` | Adds `;` for command mode and `jk` to leave insert mode. |

Prettier is referenced by the formatter configuration but is not installed by
this module. Formatting falls back to the active LSP where supported. The
generated `lazy-lock.json` is ignored by the repository, so plugin versions are
synchronized from the current plugin specifications rather than a committed
lock file.

The probe only requires a working `nvim --version`; optional formatters,
language servers, and plugins do not affect `./install --status`.
