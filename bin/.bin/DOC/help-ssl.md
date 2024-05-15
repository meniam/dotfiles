Помощь по SSL
=============

Установка
=========

## Подготавливаем систему

```bash
sudo apt-get install git bc wget curl socat idn
```

## Добавить на reg.ru IP-сервера в разрешенные

https://www.reg.ru/user/prefs/security

```bash

openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096

```

## Устанавливаем acme.sh

```bash
git clone https://github.com/acmesh-official/acme.sh.git
cd ./acme.sh
./acme.sh --install -m email@domain.com
```

## Переключаем сервер сертификации

```bash
acme.sh --set-default-ca  --server letsencrypt
```


Настройка
=========

Нужно скопировать со старого сервера конфиг:

```bash
mcedit /root/.acme.sh/account.conf
```

## Генерация

```bash
acme.sh --issue --dns dns_regru -d 'sanvrn.ru' -d '*.sanvrn.ru' --debug
acme.sh --issue --dns dns_regru -d 'alitr.ru' --debug

acme.sh --issue --dns dns_regru -d 'voronezh.in' -d '*.voronezh.in' --debug
acme.sh --issue --dns dns_regru -d 'voronezhin.ru' -d '*.voronezhin.ru' --debug


```

## Деплой

```bash
acme.sh --install-cert -d sanvrn.ru \
 --cert-file /etc/nginx/ssl/sanvrn.crt \
 --key-file /etc/nginx/ssl/sanvrn.key \
 --fullchain-file /etc/nginx/ssl/sanvrn.fullchain \
 --reloadcmd "systemctl reload nginx.service"
``

## AliEro

```bash
acme.sh --issue --dns dns_regru --dnssleep 60 -d 'aliero.ru' --debug
acme.sh --install-cert -d aliero.ru \
 --cert-file /etc/nginx/ssl/aliero.crt \
 --key-file /etc/nginx/ssl/aliero.key \
 --fullchain-file /etc/nginx/ssl/aliero.fullchain \
 --reloadcmd "systemctl reload nginx.service"
```

## AliTr

```bash
acme.sh --issue --dns dns_regru -d 'alitr.ru' --debug
acme.sh --install-cert -d alitr.ru \
 --cert-file /etc/nginx/ssl/alitr.crt \
 --key-file /etc/nginx/ssl/alietr.key \
 --fullchain-file /etc/nginx/ssl/alitr.fullchain \
 --reloadcmd "systemctl reload nginx.service"
```

## Voronezh.in

```bash
acme.sh --issue --dns dns_regru -d 'voronezh.in' -d '*.voronezh.in' --debug
acme.sh --install-cert -d voronezh.in \
 --cert-file /etc/nginx/ssl/voronezh.in.crt \
 --key-file /etc/nginx/ssl/voronezh.in.key \
 --fullchain-file /etc/nginx/ssl/voronezh.in.fullchain \
 --reloadcmd "systemctl reload nginx.service"
```

```bash
acme.sh --issue --dns dns_regru -d 'voronezhin.ru' -d '*.voronezhin.ru' --debug
acme.sh --install-cert -d voronezhin.ru \
 --cert-file /etc/nginx/ssl/voronezhin.ru.crt \
 --key-file /etc/nginx/ssl/voronezhin.ru.key \
 --fullchain-file /etc/nginx/ssl/voronezhin.ru.fullchain \
 --reloadcmd "systemctl reload nginx.service"
```

```bash
acme.sh --issue --dns dns_regru -d 'evirma.io' -d '*.evirma.io' --debug
acme.sh --install-cert -d evirma.io \
 --cert-file /etc/nginx/ssl/evirma.io.crt \
 --key-file /etc/nginx/ssl/evirma.io.key \
 --fullchain-file /etc/nginx/ssl/evirma.io.fullchain \
 --reloadcmd "systemctl reload nginx.service"
```

```bash
acme.sh --issue --dns dns_regru --dnssleep 60 -d 'evirma.ru' -d '*.evirma.ru' --debug
acme.sh --install-cert -d evirma.ru \
 --cert-file /etc/nginx/ssl/evirma.ru.crt \
 --key-file /etc/nginx/ssl/evirma.ru.key \
 --fullchain-file /etc/nginx/ssl/evirma.ru.fullchain \
 --reloadcmd "systemctl reload nginx.service"
```
