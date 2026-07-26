# Repository Instructions

This repository currently contains only the modular installation layer.

- Do not add, migrate, or generate dotfile configurations, modules, profiles, templates, or documentation unless the user explicitly requests them.
- Keep installer code compatible with Bash 3.2 on macOS and Bash on Debian/Ubuntu Linux.
- Keep the project, source comments, command output, documentation, and commit messages in English.
- Preserve the installer layout: `install` is the entry point and `lib/` contains shared shell helpers.
- Validate shell changes with `bash -n` and ShellCheck when it is available.
- Before every commit or deployment, inspect the changed files for sensitive information. This includes tokens, credentials, API keys, access details, personal names, email addresses, private URLs, hostnames, and other personal or account data. Do not commit or deploy until such data has been removed or moved to an appropriate untracked local file.
