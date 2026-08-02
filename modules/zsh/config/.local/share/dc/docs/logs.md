# logs

Follows the logs and keeps printing new lines until Ctrl+C.

---

**docker compose logs -f [service...]**

---

With no service the output of every container is interleaved and each line is prefixed with the service name it came from. Picking one service reads it on its own, which is what makes a noisy project readable.

Ctrl+C stops following only; the containers keep running. Nothing is written to the terminal until a container writes to stdout or stderr, so a silent process looks the same as a stopped one — `docker compose ps` is what tells them apart.

Only output the container itself produced is here. A process logging to a file inside the image is invisible to Compose, and so is anything written before the current container was created, since the log dies with the container it belonged to.

For a shorter view, `docker compose logs --tail=100 web` prints the last hundred lines and returns, and `--since=10m` limits the history by time.
