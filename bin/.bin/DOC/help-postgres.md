Помощь по Postgres
==================

```bash

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

apt update && apt -y upgrade && apt -y install postgresql-14 postgresql-server-dev-14 make build-essential

```

Extensions
==========

```bash

mkdir ~/Source
git clone git@github.com:evirma/pg_smlar.git ~/Source/smlar
cd ~/Source/smlar && make USE_PGXS=1 && make USE_PGXS=1 install

git clone git@github.com:evirma/pg_bktree.git ~/Source/bktree
cd ~/Source/bktree && make USE_PGXS=1 && make USE_PGXS=1 install

rm -rf ~/Source/smlar ~/Source/bktree

```

Настройка папки с базой
=======================

Базу лучше хранить на диске nvme.

/etc/fstab

```bash
UUID=2ef2c10d-0508-48e7-939e-886bf1e5a21b /postgresql ext4 noatime,errors=remount-ro,discard,data=ordered,defaults 0 0
tmpfs /postgresql/main/pg_stat_tmp tmpfs rw,size=1024M,noatime,mode=0777 0 0
/postgresql/main /var/lib/postgresql/14/main none bind 0 0
```


Мониторинг
==========

https://wiki.postgresql.org/wiki/Monitoring
