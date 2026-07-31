# mise

Per-project versions of Node, Python, Go, and the rest of the toolchain, chosen
by the directory the shell is in.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none

macOS installs the `mise` Homebrew formula. Debian and Ubuntu get the upstream
APT repository at `https://mise.jdx.dev/deb`, signed by the key from
`https://mise.jdx.dev/gpg-key.pub` and pinned to it with `signed-by`, so system
updates keep mise current. The repository publishes `amd64` and `arm64` only;
`setup.sh` refuses to add it on any other architecture instead of leaving an APT
source that never resolves.

The module installs the binary and one settings fragment. It does not install a
single language runtime — that happens the first time a project asks for one.

## Where the configuration lives

| Path | Owner | Contents |
| --- | --- | --- |
| `~/.config/mise/conf.d/00-dotfiles.toml` | this repository, via stow | Settings only. |
| `~/.config/mise/config.toml` | the machine, created empty by `setup.sh` | Global tool versions written by `mise use -g`. |

The split is not cosmetic. `mise use`, `mise set`, and `mise settings set` write
to the *lowest precedence file in the highest precedence directory*, and in
`~/.config/mise` the `conf.d` fragments rank below `config.toml`. With no
`config.toml` present, `mise set -g FOO=bar` appends to the fragment — a symlink
into this repository — and the global environment turns into an uncommitted
repository change. Creating an empty `config.toml` gives those writes a target
that stow does not own, which is why `setup.sh` creates it and why the probe
checks for it.

The fragment enables two settings:

- `idiomatic_version_file_enable_tools = ["node"]` makes mise read `.nvmrc`,
  `.node-version`, and the `package.json` engines field. mise ignores every one
  of them by default and looks only at `mise.toml` and `.tool-versions`, so a
  project that never adopted mise would silently keep running whatever Node is
  on `PATH`. With the setting on, `mise ls --current` in a directory holding an
  `.nvmrc` of `20` reports `node 20.x` with `.nvmrc` as its source.
- `status.show_tools = true` prints the tools a directory activates when they
  differ from the current ones, so a version switch is visible rather than
  silent. Set it to `false` in `~/.config/mise/config.toml` to get the quiet
  behavior back.

## Shell activation

The `zsh` module evaluates `mise activate zsh` when the binary is present. That
line defines a `mise` shell function, registers a `precmd` hook, and rewrites
`PATH` on every prompt from the config files that apply to the current
directory. In a directory with no pin, mise adds nothing and Homebrew's
`node@24` — or whatever the `node24` module installed — stays in charge.

Activation happens in `30-env.zsh`, which `.zshrc` sources for interactive
shells only. Scripts, cron jobs, and IDEs that spawn a non-interactive shell
therefore do not get the per-directory `PATH`. Use `mise exec -- <command>` for
one call, or add the shim directory
`${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims` to the `PATH` of the tool that
needs it. Shims resolve versions without the hook at the cost of not exporting
`[env]` variables from `mise.toml`.

Other shells are not wired up by this repository. For bash, add
`eval "$(mise activate bash)"` to the machine-local rc file.

## Trust

A `mise.toml` that declares `[env]` is rejected until the project is trusted:

```
mise ERROR Config files in /path/to/project/mise.toml are not trusted.
Trust them with `mise trust`.
```

Run `mise trust` once in the project. Tool pins and tasks load without it — the
gate exists because `[env]` injects variables into every command run in that
directory tree, which a freshly cloned repository should not be able to do
unasked. Directory trees that should skip the check entirely go into
`trusted_config_paths` in `~/.config/mise/config.toml`.

## Everyday commands

```bash
mise use node@20          # pin in ./mise.toml and install
mise use -g node@lts      # global default in ~/.config/mise/config.toml
mise install              # install everything the current directory pins
mise ls --current         # active versions and the file each one came from
mise cfg                  # config files in effect here, in precedence order
mise exec -- node --version
```

`.tool-versions` from asdf is read as-is, so an existing asdf project needs no
conversion.

## Relationship with the other modules

**`node24`** installs one fixed Node through Homebrew or NodeSource and links it
onto `PATH`. mise overrides it only inside a project that pins a version;
everywhere else `node` remains the `node24` build. Keeping both is reasonable —
one is the machine-wide default, the other is the per-project override — but a
machine that has fully moved to mise does not need `node24` at all.

**`direnv`**, installed by the `must-have` module, is the part that needs care.
Both tools inspect the environment before and after their own hook and both
manage `PATH`, and mise's maintainers state that direnv is not supported
alongside `mise activate`: incompatibilities are not treated as bugs. In
practice they coexist as long as the split is respected — mise owns tools and
`PATH`, direnv owns plain environment variables. Two rules follow:

- Do not use `PATH_add`, `layout python`, `layout node`, or any other `.envrc`
  directive that edits `PATH`. Pin the tool in `mise.toml` instead.
- If a project genuinely needs direnv to control `PATH`, drop `mise activate`
  for it and export `MISE_NODE_VERSION`-style variables from `.envrc`, or
  generate `use_mise` with `mise direnv activate > ~/.config/direnv/lib/use_mise.sh`.

Hook order is not a matter of taste here: `direnv hook zsh` prepends itself to
`precmd_functions` no matter where it is evaluated, so the resulting order is
`_direnv_hook` then mise's hook. mise runs last and has the final word on
`PATH`, which is the behavior worth keeping. The visible consequence is that a
variable defined in both `mise.toml` and `.envrc` resolves to the mise value.

## Uninstalling

APT and Homebrew remove the binary. The repository definition on Linux stays
behind in `/etc/apt/sources.list.d/mise.list` and `/etc/apt/keyrings/mise.gpg`
and has to be deleted by hand. Installed runtimes live in
`${XDG_DATA_HOME:-$HOME/.local/share}/mise` and survive both.
