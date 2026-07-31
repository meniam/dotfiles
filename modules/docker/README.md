# Docker

Docker runtime and terminal interfaces for inspecting containers, images,
volumes, logs, and Compose projects.

- Platforms: macOS and Linux
- Default: off
- Dependencies: none
- Linux distribution support: Debian only

## Included tools

| Utility | Purpose |
| --- | --- |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Provides Docker Engine, Compose, and the desktop application on macOS. |
| [Docker Engine](https://docs.docker.com/engine/) | Runs containers through Docker's official Debian packages. |
| [Oxker](https://github.com/mrjackwills/oxker) | Displays and controls containers in a terminal interface. |
| [LazyDocker](https://github.com/jesseduffield/lazydocker) | Provides a terminal interface for Docker and Compose resources. |

## macOS installation

Homebrew installs the `docker` cask plus the `oxker` and `lazydocker`
formulae. The installation probe checks for `/Applications/Docker.app` and
both terminal interfaces; it does not require Docker Desktop to be running.

## Debian installation

`setup.sh` performs these steps:

1. Refuses to continue when conflicting `docker.io`, `docker-compose`,
   `docker-doc`, `podman-docker`, `containerd`, or `runc` packages are installed.
2. Installs Docker's signing key and Deb822 repository at
   `/etc/apt/keyrings/docker.asc` and `/etc/apt/sources.list.d/docker.sources`.
3. Installs Docker Engine, the CLI, containerd, Buildx, and the Compose plugin
   from Docker's official repository.
4. Downloads the current Oxker release for x86_64 or arm64 into
   `~/.local/bin` when Oxker is absent.
5. Runs LazyDocker's upstream installer with `DIR=~/.local/bin` when
   LazyDocker is absent.

The module does not remove conflicting packages, add the current user to the
`docker` group, or configure daemon settings. Perform those security-sensitive
steps separately when needed.

## Configuration and status

The tracked `~/.config/lazydocker/config.yml` is intentionally empty, so
LazyDocker uses its upstream defaults while the path remains ready for future
tracked settings.

On Linux, the probe requires `docker compose`, Oxker, and LazyDocker. The
module declares generic Linux support for installer selection, but setup exits
with an error on Linux distributions other than Debian.
