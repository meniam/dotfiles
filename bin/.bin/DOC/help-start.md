Настройка новой системы Debian
==============================

### 1. Установка базовых пакетов и базовая настройка

```(bash)

# Ставим пакеты

apt update && apt -y upgrade && \
apt -y install \
    vim zsh mc sudo screen git tmux tmuxinator bat fzf pydf pwgen tilde tree thefuck fd-find \
    coreutils net-tools dnsutils build-essential imagemagick htop iotop iftop wget curl stow \
    fasd ffmpeg jq lynx nano peco shellcheck \
    cmake nasm pngquant libpng-dev idn bc socat \
    pandoc html2text

# Настраиваем Time Zone

timedatectl set-timezone Europe/Moscow
apt -y install ntp && service ntp restart

# Настраиваем локаль

dpkg-reconfigure locales
mcedit /etc/default/locale

-----
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
-----

```

### Настройка сети

[Как настроить V3 Vpn на Selectel](https://kb.selectel.ru/docs/networks-services/l3_vpn/routes/)

Общая идея: настраивается роутер и внутри две сети, на каждом сервере gateway на .254 в своей сети

```

```

### Настраиваем zsh


### Настройка дисков

```bash

fdisk -l

fdisk /dev/sdaX
> g 
> n
> w

```

Обязательно использовать fstrim

```bash
# только для SSD
mkfs.ext4 -E discard /dev/sdaX
tune2fs -o discard /dev/nvme1n1p1
tune2fs -o discard /dev/sda1

sudo cp /usr/share/doc/util-linux/examples/fstrim.{service,timer} /etc/systemd/system
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

```

Раздел TMP лучше отправить в память

```bash

mcedit /etc/fstab
tmpfs /tmp tmpfs rw,nosuid,nodev 0 0

```

**limits**

```bash

mcedit /etc/security/limits.conf

*                soft    nofile          1024000
*                hard    nofile          1024000
root             hard    nofile          1024000
root             soft    nofile          1024000
        
```

**Scheduler**

```bash
mcedit /etc/modules-load.d/bfq.conf
> bfq

mcedit /etc/udev/rules.d/60-scheduler.rules
# set deadline scheduler for non-rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]n[0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"

# set deadline scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]n[0-9]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="deadline"

cat /sys/block/sda/queue/scheduler
echo "bfq" > /sys/block/sda/queue/scheduler


```

**Журналирование и форматирование**

- Для корневого лучше ORDERED
- Для статики лучше WRITEBACK
- Для критичных данных лучше JOURNAL


```bash

# Для SSD

tune2fs -o discard /dev/sdaX
mkfs.ext4 -E discard /dev/sdaX

# индексация директорий
tune2fs -O dir_index /dev/sda1
e2fsck -fD /dev/sda1

mcedit /etc/fstab

# mount options root и остальные
# noatime,nodiratime,discard,data=ordered,errors=remount-ro,defaults

# static mount options (Не используем)
# noatime,discard,data=writeback,barrier=0,nobh,errors=remount-ro

```

**Доп справка по журналированию**

**data=writeback** файловая система не производит какого либо журналирования данных. При неожиданных перезагрузках системы это может вызвать потерю данных в обновляемых файлах. Данный режим обеспечивает самую высокую производительность.

**data=ordered** файловая система журналирует только метаданные (данные и методанные группируются в один модуль - транзакцию). Этот режим, хотя без гарантии, защищает данные при неожиданной перезагрузке, в отличае от предыдущего. Тем не менее полного журналирования не происходит. Производительность уступает data=writeback, но она гораздо быстрее полного журналирования.

**data=journal** обеспечивает полное журналирование метаданных и самих данных. Данные сначала пишутся в журнал и потом только переносятся на постоянное место. При аварийных ситуациях журнал можно перечитать - приведя данные в непротиворичивое состоянние. Данный режим самый медленный, но в отдельных случаях он показывает хорошие результаты. Он имеет преимущества при одновременных операциях ввода/вывода данных (при записи и одновременном чтении, скорость чтения в тестах была выше на порядок чем при других режимах).

**Внимание: **для использования любого другого режима, кроме*data=ordered*для корневой файловой системы, вам придется задать в параметрах загрузки ядра (*boot/grub/menu.lst*) следующую строку:

rootflags=data=writeback

Интересно про настройку FS:
https://www.linux.org.ru/forum/general/8030866

**huge pages**

```bash

mcedit /etc/default/grub
> GRUB_CMDLINE_LINUX="default_hugepagesz=128M hugepagesz=128M hugepages=1024"
sudo update-grub

```

**sysctl**

http://gorodovets.blogspot.com/2009/12/installing-oracle10gr2-on-rhel-5oel-5.html

```config


```

**nginx**

```
mcedit /etc/apt/sources.list.d/nginx.list
deb http://nginx.org/packages/mainline/debian/ buster nginx

sudo wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key

apt update && apt install nginx
```

**Обработка картинок**

```bash

apt install cmake nasm pngquant libpng-dev 

git clone https://github.com/mozilla/mozjpeg.git
cd mozjpeg
cmake -G"Unix Makefiles"
make -j4 
make install

```



** Xvfb ** 

```bash

apt -y install xorg xvfb gtk2-engines-pixbuf dbus-x11 xfonts-base xfonts-100dpi xfonts-75dpi xfonts-cyrillic xfonts-scalable imagemagick x11-apps libnss3-dev libgdk-pixbuf2.0-dev libgtk-3-dev libxss-dev

Xvfb -ac :99 -screen 0 1280x1024x16 & export DISPLAY=:99


```
