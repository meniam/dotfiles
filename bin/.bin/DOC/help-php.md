Настройка php 8.1
=================

```bash

apt -y install lsb-release apt-transport-https ca-certificates &&\
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg &&\
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list &&\
apt update && apt -y install php8.1-{common,igbinary,msgpack,mysql,pgsql,xsl,xml,curl,gd,cli,dev,mbstring,opcache,zip,intl,bcmath,bz2,fpm,gmp,apcu,memcached}

```
