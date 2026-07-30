# Multiplexer

Terminal multiplexer tools: [tmux](https://github.com/tmux/tmux) and [herdr](https://herdr.dev), an agent multiplexer.

The module links `~/.config/tmux/tmux.conf` and installs [TPM](https://github.com/tmux-plugins/tpm) plus the plugins it declares. `yank.sh`, `renew_env.sh`, and `tmux.remote.conf` are bundled from [samoshkin/tmux-config](https://github.com/samoshkin/tmux-config), which this configuration is based on. `herdr` installs via Homebrew on macOS or the official `herdr.dev/install.sh` script on Linux; its configuration is linked to `~/.config/herdr`.
