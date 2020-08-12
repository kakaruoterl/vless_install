#! /bin/bash

systemctl stop nginx
systemctl stop haproxy
~/.acme.sh/acme.sh --renew -d example.com --force --ecc
~/.acme.sh/acme.sh --installcert -d example.com --ecc --fullchain-file /etc/v2ray/v2ray.crt --key-file /etc/v2ray/v2ray.key
cat /etc/v2ray/v2ray.crt /etc/v2ray/v2ray.key > /etc/ssl/private/v2ray.pem
systemctl start nginx
systemctl start haproxy