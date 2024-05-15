Помощь по hosts
===============

```bash
vim /etc/hosts
```

```bash
#######################################
# Добавляется в конец файла /etc/hosts
#######################################

#
# Сервера инфраструктуры
#

192.168.0.156 app
192.168.0.157 static
192.168.0.158 db

# 116.202.134.254 app.server
# 127.0.0.1 app-server

#
# postgres, elasticsearch
#
192.168.0.158 db-slave-server elastic-server

#
# memcached
#
127.0.0.1 memcache-server memcached-server

#
# Настройка имени текущего сервера
# > extenal {code}.server
# > 127.0.0.1 {code}-server
#

```
