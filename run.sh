#!/bin/sh

set -eou pipefail

openssl dhparam -out /etc/nginx/ssl/dhparams.pem 2048

(
  IFS=","
  for domain in $DOMAINS ; do
    touch "/etc/nginx/ssl/${domain}.conf"
    echo "Stubbed: /etc/nginx/ssl/${domain}.conf"
  done
)

nginx

(
  IFS=","
  for domain in $DOMAINS ; do
    certbot \
      certonly \
      --webroot \
      -w /var/www/certbot_webroot \
      -d "${domain}" \
      --agree-tos \
      --email engineering@vincari.com \
      --noninteractive
    echo -e "
      ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;
    " > "/etc/nginx/ssl/${domain}.conf"
    echo "Wrote: /etc/nginx/ssl/${domain}.conf"
  done
)

touch /var/log/certbot-renew.log
touch /var/log/nginx/access.log
touch /var/log/nginx/error.log

nginx -s reload

crond

tail -F /var/log/nginx/*.log /var/log/certbot-renew.log
