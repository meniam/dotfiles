# SSH

Client-side defaults for OpenSSH.

- Platforms: macOS and Linux
- Default: on
- Dependencies: none

The module installs no software on macOS: the system already ships Apple's
OpenSSH at `/usr/bin/ssh`, and installing the Homebrew build would shadow it
and drop the `UseKeychain` patch that only Apple carries. On Debian/Ubuntu it
installs `openssh-client`, which a minimal image can be missing.

Everything else is one payload, `~/.ssh/config`, plus a `setup.sh` that creates
the directory the multiplexing sockets live in. The setup also restricts
`~/.ssh` and `~/.ssh/sockets` to mode `0700`.

## Include order

Unlike Git, ssh keeps the **first** value it obtains for a keyword and ignores
every later one. A `Host *` block placed at the top of a config therefore locks
in its settings permanently — nothing further down, in this file or in an
included one, can override them.

So the includes come first and the catch-all block comes last:

```sshconfig
Include ~/.ssh/config.local
Include ~/.ssh/config.d/*.conf

Host *
    ...
```

Per-host entries in `~/.ssh/config.local` win, and `Host *` only supplies the
keywords nothing else claimed. Neither include has to exist: ssh skips an
include path that does not resolve without warning.

Both live outside the repository. `config.local` is the single-file escape
hatch for private hosts, users, ports, jump hosts, and identity files;
`config.d/*.conf` is there for splitting that up per project or per employer.
Keeping them out of the repo is what allows the module to be public — no
hostnames, usernames, or key paths are committed.

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
Set it per host in `config.local`, next to the `IdentityFile` it applies to,
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

Add the keyword to `config.local` if that trade is worth it on a given machine.

**Cipher, MAC, and key exchange lists** are not pinned either. A hardcoded list
ages into either a weak configuration or one that cannot reach older servers;
the upstream defaults track current practice on their own.

## Replacing an existing config

The installer moves a pre-existing `~/.ssh/config` into
`~/.dotfiles-backups/<timestamp>-<pid>/` before stow links this one, so nothing
is lost. Private host entries from the backup belong in `~/.ssh/config.local`,
where the `Include` picks them up and where they stay out of version control.
