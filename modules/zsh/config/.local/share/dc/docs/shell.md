# shell

Opens an interactive shell inside one running container.

---

**docker compose exec &lt;service&gt; bash**

---

Exactly one service, and it has to be running: `exec` attaches to a live container. Many small images ship no bash, so the shortcut asks for `bash` and falls back to `sh` inside the container rather than failing.

If the service is stopped, or crashes before it can be attached to, use `docker compose run --rm <service> sh` instead. That starts a fresh container from the same image, which is also the way to look at an image whose entrypoint is what breaks.

Anything changed in here lives in the container's writable layer and is lost the next time `up` or `rebuild` recreates it. Install a package to test an idea, then put it in the Dockerfile. Edit project files on the host, where the bind mount makes them visible on both sides.

Exiting the shell leaves the container running, since only the `exec` process ends.
