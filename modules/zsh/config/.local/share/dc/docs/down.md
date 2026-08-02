# down

Stops the containers and removes them together with the project network.

---

**docker compose down [service...]**

---

Named volumes and built images are kept, so the data is still there and the next `up` starts from the same state. Removing the volumes is `docker compose down -v` — deliberately not one of the shortcuts here, because it deletes databases.

Anything written inside a container outside a volume is gone: the writable layer disappears with the container. Uploads, caches, and hand-installed packages living in the image filesystem do not survive.

Use `docker compose stop` instead when the containers should stay on disk and be startable again with `docker compose start`, which keeps their state and their writable layer.

With no service the whole project goes down, including its network. Naming a service removes only that container and leaves the network and the other services running.
