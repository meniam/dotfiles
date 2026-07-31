# Python

A Python development toolchain built around [uv](https://docs.astral.sh/uv/):
interpreters, virtual environments, and developer tools are all managed by uv
instead of by Homebrew, APT, or pip.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none

## Included tools

| Utility | Purpose |
| --- | --- |
| [uv](https://docs.astral.sh/uv/) | Installs interpreters, resolves and locks dependencies, and manages virtual environments and tools. |
| `uvx` | Runs a published tool in a throwaway environment; installed next to `uv`. |
| [Ruff](https://docs.astral.sh/ruff/) | Lints and formats Python code. |
| [ty](https://docs.astral.sh/ty/) | Checks types. The tool is in preview upstream, so its diagnostics and options still change. |
| CPython | A uv-managed interpreter, downloaded during setup and used by every environment uv creates. |

## Configuration

| Target | Purpose |
| --- | --- |
| `~/.config/uv/uv.toml` | Machine-wide uv defaults: managed interpreters only and automatic interpreter downloads. |
| `~/.config/python/startup.py` | Interactive-interpreter startup file that creates the directory of the REPL history file. |

A project's own `uv.toml` or `[tool.uv]` table overrides the user-level file, so
per-project index, resolution, and interpreter settings stay in the project.

`python-preference = "only-managed"` makes uv ignore Homebrew, APT, and Xcode
interpreters. Those packages are upgraded independently of any project, which
silently breaks virtual environments built against them. The trade-off is that an
interpreter version uv has not downloaded yet requires network access.

## Interpreter and REPL notes

The module does not put a `python` or `python3` command on `PATH`. Use
`uv run`, `uv run python`, or a project environment created by `uv venv`; the
system `python3` remains whatever the platform provides.

The `zsh` module exports `PYTHONSTARTUP` and `PYTHON_HISTORY` only when the
stowed startup file exists, so a shell-only install without this module keeps
CPython's defaults. With both set, interactive history is stored in
`~/.cache/python/history`. `PYTHON_HISTORY` is read by Python 3.13 and later;
older interpreters ignore it and keep using `~/.python_history`.

## Platform and setup notes

- No Homebrew or APT manifest is used. `setup.sh` installs uv from the official
  `astral.sh/uv/install.sh` script into `~/.local/bin` when no `uv` is already on
  `PATH`, and runs it with `INSTALLER_NO_MODIFY_PATH=1` because the `zsh` module
  owns `PATH`.
- `setup.sh` then downloads a uv-managed CPython when none is installed, and
  installs Ruff and ty with `uv tool install`. Each tool gets its own environment
  under uv's tool directory and is linked into `~/.local/bin`.
- Repeated runs are offline: an existing uv, managed interpreter, and tool are
  detected and skipped.
- The probe requires `uv`, `uvx`, `ruff`, and `ty` on `PATH` plus at least one
  uv-managed interpreter. Restart the shell after the first installation if
  `~/.local/bin` is not yet on `PATH`.
- Upgrades are not part of setup. Use `uv self update`, `uv tool upgrade --all`,
  and `uv python upgrade` when a newer release is wanted.
