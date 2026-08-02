# rebuild

Builds the images from scratch, then starts the project on them.

---

**docker compose build --pull --no-cache [service...]**

**docker compose up -d --force-recreate [service...]**

---

`--no-cache` ignores every cached layer and `--pull` fetches a newer base image, so the result matches a build on a machine that has never seen this project. That is also why it is slow: expect the full dependency install every time.

Reach for it when the cache is lying — the base image moved under a tag such as `node:22`, a package index was stale during the last build, or a `COPY` produced a layer Compose still considers current. For an ordinary code change, `docker compose build` followed by `dc up` reuses the cache and is much faster.

Services declared with only an `image:` and no `build:` have nothing to build; the build step skips them and the `up` still recreates their containers.

Nothing is removed. The previous images stay behind untagged and keep occupying disk until `docker image prune` reclaims them, which is worth remembering after a few rebuilds of a large image.
