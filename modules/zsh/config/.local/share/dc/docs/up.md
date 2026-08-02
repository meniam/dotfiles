# up

Starts the project in the background and replaces every container.

---

**docker compose up -d --force-recreate [service...]**

---

`--force-recreate` recreates the containers even when Compose considers their configuration unchanged. That is the reason to type `dc up` instead of plain `up -d`: a container edited by hand, left in a bad state, or started from an image that has since been rebuilt is thrown away and made again from the current Compose file.

Images are **not** rebuilt here. After changing a Dockerfile or the files it copies in, use `rebuild`, or `docker compose build` followed by `dc up` when the layer cache is trustworthy.

Existing named volumes and their data survive; only `docker compose down -v` removes them. Containers that are running are stopped and replaced, so a service holding an open connection drops it.

With no service the whole project starts, including its dependencies. Naming a service starts that service plus whatever its `depends_on` requires, and leaves the rest of the project alone.

Follow it with `docker compose logs -f` to watch the containers come up, since `-d` returns as soon as they are started, not when the processes inside are ready.
