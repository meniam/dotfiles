# SSH

Client-side defaults for OpenSSH.

- Platforms: macOS and Linux
- Default: on
- Dependencies: none

OpenSSH itself is never installed from Homebrew: macOS already ships Apple's
build at `/usr/bin/ssh`, and the formula would shadow it and drop the
`UseKeychain` patch that only Apple carries. On Debian/Ubuntu the module
installs `openssh-client`, which a minimal image can be missing. Both platforms
also get a few tools that work alongside ssh rather than replace it.

| Utility | Purpose |
| --- | --- |
| [keychain](https://www.funtoo.org/Funtoo:Keychain) | Keeps one ssh-agent shared across logins, tmux panes, and cron jobs. |
| [ssh-audit](https://github.com/jtesta/ssh-audit) | Reports the algorithms a server accepts and flags the weak ones. |
| [sshuttle](https://github.com/sshuttle/sshuttle) | Tunnels arbitrary traffic over a plain SSH login, with no server-side setup. |
| [autossh](https://www.harding.motd.ca/autossh/) | Restarts a tunnel when it dies, which `mosh` does not cover. |

The payload is `~/.ssh/config.d/zz-defaults.conf` plus one Zsh fragment (see
below). `setup.sh` seeds a plain `~/.ssh/config` that includes it, creates
`~/.ssh/sockets`, and restricts both directories and `~/.ssh` itself to mode
`0700`.

## Reaching an agent

`AddKeysToAgent yes` hands a decrypted key to a running `ssh-agent` so the
passphrase is asked once instead of on every connection. It is a silent no-op
when no agent is reachable — nothing fails, the prompt simply comes back every
time.

macOS wires `SSH_AUTH_SOCK` up through launchd before any shell starts, so
there is nothing to do there. Linux starts no agent on its own, which is what
`config/.config/zsh/35-ssh-agent.zsh` handles: it prefers `keychain`,
which reuses a single agent machine-wide, and otherwise starts one `ssh-agent`
per user and records its address so later shells attach instead of spawning
another.

The fragment lives in this module rather than in `zsh` on purpose. `.zshrc`
sources every `[0-9][0-9]-*.zsh` in that directory, so installing `ssh` is
enough for it to take effect, and a machine without the module never has the
file. For any other shell the equivalent belongs in a machine-local rc file.

## Include order

Unlike Git, ssh keeps the **first** value it obtains for a keyword and ignores
every later one. A `Host *` block read early therefore locks in its settings
permanently — nothing read after it can override them.

`~/.ssh/config` is a regular file that belongs to the machine. `setup.sh`
creates it when it is missing and otherwise only makes sure it includes
`config.d` (see [Replacing an existing config](#replacing-an-existing-config)):

```sshconfig
Include ~/.ssh/config.d/*.conf
```

The repository owns only `config.d/zz-defaults.conf`, which holds the
`Host *` block. The glob expands in lexical order and the `zz-` prefix sorts it
after every other drop-in, so per-host entries in `config.d/*.conf` are read
first and win, and `Host *` only supplies the keywords nothing else claimed.
ssh skips a glob that matches nothing without warning, so no drop-in has to
exist besides the defaults.

Keep hosts out of `~/.ssh/config` itself. An `Include` that follows a `Host`
line applies only to that host, so host blocks there would have to sit after
the `Include` and would lose to the defaults.

The split exists because tools such as OrbStack, Colima, or VS Code Remote
edit `~/.ssh/config` on their own. When it was a symlink into the repository,
those edits landed in the tracked file; now they stay on the machine. An older
install that still has the symlink gets it replaced by the seeded file on the
next `setup.sh` run.

Private hosts, users, ports, jump hosts, and identity files go in
`config.d/*.conf`, one file per project or per employer. Keeping them out of
the repo is what allows the module to be public — no hostnames, usernames, or
key paths are committed.

## What the defaults do

| Keyword | Effect |
| --- | --- |
| `IgnoreUnknown UseKeychain` | Marks the next keyword optional. Portable OpenSSH rejects an entire config on an unrecognised keyword, so without this line every `ssh` call on Linux would fail with `Bad configuration option: usekeychain`. |
| `UseKeychain yes` | macOS only: reads a key's passphrase from the login keychain instead of prompting. Silently ignored elsewhere thanks to the line above. |
| `AddKeysToAgent yes` | A passphrase typed once is added to the running agent for the rest of the session. |
| `ControlMaster auto` | The first connection to a host becomes a master; later ones ride the same TCP session and skip the handshake entirely. |
| `ControlPath ~/.ssh/sockets/%C` | Where the master's socket lives. `%C` is a fixed-length hash of `%l%h%p%r`. |
| `ControlPersist 10m` | The master stays up for ten minutes after the last session exits, so a burst of `git fetch` calls authenticates once. |
| `ServerAliveInterval 60` / `ServerAliveCountMax 3` | Probe the peer through the encrypted channel and drop the connection after three unanswered probes, so a stale master does not survive a network change. |
| `TCPKeepAlive no` | Redundant once the encrypted keepalive above is on, and spoofable, so it is turned off. |

### Why `%C` and not `%r@%h:%p`

A unix domain socket path is limited to roughly 104 bytes on macOS and 108 on
Linux. `~/.ssh/sockets/` already spends part of that, and a long user name plus
a long hostname can push the rest past the limit — at which point multiplexing
stops working with no obvious explanation. `%C` hashes the same four values
into a constant-width name and cannot overflow.

The trade-off is that socket names are no longer human-readable. `ssh -O check
<host>` and `ssh -O exit <host>` still resolve the right socket, so the name
rarely needs to be read directly.

### Recovering from a stuck master

If the far end reboots or the local network changes, the cached master can hang
until the keepalives time out. To drop it immediately:

```bash
ssh -O exit <host>
```

## Deliberately not set

Two common defaults are left out because they are the wrong choice here, not
because they were overlooked.

**`IdentitiesOnly yes`** restricts ssh to the identities named in the config
and stops it from offering everything the agent holds. It is the usual fix for
`Too many authentication failures` on a machine with many keys. It also makes
agent-only keys unusable — keys held by 1Password, Secretive, or a YubiKey
have no file on disk to name, so ssh would stop offering them entirely.
Set it per host in a `config.d` drop-in, next to the `IdentityFile` it applies to,
rather than globally:

```sshconfig
Host example
    HostName ...
    IdentityFile ~/.ssh/id_example
    IdentitiesOnly yes
```

**`HashKnownHosts yes`** replaces the hostname in each `~/.ssh/known_hosts`
entry with an HMAC of it, so someone reading the file cannot enumerate the
servers this machine connects to. The cost is that `grep` over the file stops
working, shell completion of host names from it produces nothing, and the file
can no longer be reviewed by eye. `ssh-keygen -R <host>` keeps working, since
it hashes the query before matching.

It also only affects entries added from that point on. Turning it on leaves an
existing file half readable, which buys nothing; making it meaningful requires
rewriting the whole file once:

```bash
ssh-keygen -H -f ~/.ssh/known_hosts   # the previous contents stay as known_hosts.old
```

Add the keyword to a `config.d` drop-in if that trade is worth it on a given machine.

**Cipher, MAC, and key exchange lists** are not pinned either. A hardcoded list
ages into either a weak configuration or one that cannot reach older servers;
the upstream defaults track current practice on their own.

## Replacing an existing config

`setup.sh` keeps an existing `~/.ssh/config`. When the file has no `Include`
of `config.d` yet, it prepends the `Include` line above, so it comes before
the first `Host` line and the defaults take effect. A file that already
includes `config.d` anywhere is left exactly as it is. Host entries from such a
file are best moved into a `config.d` drop-in, for the ordering reason above.
