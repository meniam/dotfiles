"""Startup file for interactive Python sessions, loaded through PYTHONSTARTUP.

Only interactive interpreters execute this file, and they execute it in the REPL's
own namespace before `sys.__interactivehook__` configures readline. A failure here
prints a traceback before every session, and every name defined here stays visible
at the prompt, so the work happens inside one guarded function that imports what
it needs locally.

That function's only job is to create the directory of the REPL history file.
CPython's history writer treats a missing directory as `FileNotFoundError` and
discards the history silently, so `PYTHON_HISTORY` pointing into the XDG cache
only keeps history once that directory exists.
"""


def _prepare_history_directory():
    """Create the parent directory of the interactive history file."""
    import os
    from pathlib import Path

    configured = os.environ.get("PYTHON_HISTORY")
    if configured:
        history = Path(configured).expanduser()
    else:
        cache_home = os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache"
        history = Path(cache_home) / "python" / "history"
    history.parent.mkdir(parents=True, exist_ok=True)


try:
    _prepare_history_directory()
except (OSError, RuntimeError):
    pass  # An unwritable cache or an undetermined home directory costs history only.

del _prepare_history_directory
