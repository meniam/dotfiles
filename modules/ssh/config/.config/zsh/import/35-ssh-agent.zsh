# Make sure an ssh-agent is reachable, so `AddKeysToAgent yes` in ~/.ssh/config
# has somewhere to put a key. Without an agent that keyword is a silent no-op
# and every connection asks for the passphrase again.
#
# This fragment belongs to the `ssh` module, not to `zsh`: .zshrc sources every
# [0-9][0-9]-*.zsh in this directory, so installing the module is enough for it
# to take effect, and a machine without the module simply never has the file.

# macOS wires SSH_AUTH_SOCK up through launchd before the shell starts, so this
# only ever runs on Linux, or wherever the variable is genuinely missing.
if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
  if (( $+commands[keychain] )); then
    # keychain reuses one agent across logins, tmux panes, and cron jobs
    # instead of leaving a fresh one behind per shell. --noask keeps it from
    # prompting at startup; the passphrase is asked once on first real use.
    eval "$(keychain --eval --quiet --noask --agents ssh)"
  elif (( $+commands[ssh-agent] )); then
    # Fallback: one agent per user, its address remembered in a file so a
    # second shell attaches to the running one rather than spawning another.
    ssh_agent_env="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/ssh-agent-${UID}.env"
    [[ -r "$ssh_agent_env" ]] && source "$ssh_agent_env" >/dev/null

    # ssh-add exits 2 when it cannot reach an agent at all, 1 when the agent is
    # there but holds no keys. Only the first case needs a new agent.
    ssh-add -l >/dev/null 2>&1
    if (( $? == 2 )); then
      (umask 077; ssh-agent -s >| "$ssh_agent_env")
      source "$ssh_agent_env" >/dev/null
    fi

    unset ssh_agent_env
  fi
fi
