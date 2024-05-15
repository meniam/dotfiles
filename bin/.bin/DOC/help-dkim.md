# Настройка DKIM

## Генерация DKIM

````bash

# Подготовка
mkdir /etc/exim4/dkim
apt-get install opendkim-tools
chown -R Debian-exim:Debian-exim /etc/exim4/dkim

```

```bash

# Генераци

OPENDKIM_D='sellerchecking.com' && opendkim-genkey -D /etc/exim4/dkim/ -d ${OPENDKIM_D} -s email.${OPENDKIM_D} && \
mv /etc/exim4/dkim/email.${OPENDKIM_D}.private /etc/exim4/dkim/email.${OPENDKIM_D}.key && \
chown -R Debian-exim:Debian-exim /etc/exim4/dkim/email.${OPENDKIM_D}.key && \
chmod 640 /etc/exim4/dkim/email.${OPENDKIM_D}.key && \
cat /etc/exim4/dkim/email.${OPENDKIM_D}.txt

```

# Настройка DNS

## DKIM ADSP
_adsp._domainkey.email TXT v=DMARC1; p=none;
_dmarc.email TXT v=DMARC1; p=none;

## MX-Record
email MX 10 email

## SPF (@see https://mxtoolbox.com/spf.aspx)
email TXT v=spf1 a mx ip4:5.182.224.92 ip4:5.182.224.76 ~all
// Обязательно на IP которые в SPF добавить A и MX записи 

## DKIM
email._domainkey.email TXT v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtVL9MG4PPk3zSDFm4cwsOOYTOFQBzCTsOtHNfSFBVHXHmHFJgWA6b0sB6ijf5MavZ26KfNzkA/mAaTHGzTPUdX9UJ6MC4+vMj7KDAMCa0QsyZpkZsUPM6S+n83Yv0E5hZIB9qvR2mkQFQyMtnpWF3x0+Pourp81eYMAmThBBob3Lx0Guq37aO7noyo2M+whgb/fFVWnZRsLKdJGTj14VSudkFjyAP2BT9e8qDnpWmzpPJXYnzdbqhNW+6QJQkEn57bgOi6TXIaoctXALCqqzHXIOVyahUaxvyFw/ucG2Cd4OdIEfrBG+KAG/vEe5AP7AcWht39gLk2v2mqF7iQOeUwIDAQAB

