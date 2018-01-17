#!/bin/sh

set -eou pipefail

openssl dhparam -out /etc/nginx/ssl/dhparams.pem 2048

baseDomain=$(echo "${DOMAINS}" | cut -f1 -d",")

touch "/etc/nginx/ssl/${baseDomain}.conf"
echo "Stubbed: /etc/nginx/ssl/${baseDomain}.conf"

nginx

certbotStagingArg="${CERTBOT_STAGING:+"--staging"}"

if [ -d "/etc/letsencrypt/live/${baseDomain}" ] ; then
  certbot renew --keep-until-expiring
else
  certbot \
    certonly \
    --webroot \
    $certbotStagingArg \
    -w /var/www/certbot_webroot \
    -d "${DOMAINS}" \
    --agree-tos \
    --email engineering@vincari.com \
    --noninteractive
fi
echo -e "
  ssl_certificate /etc/letsencrypt/live/${baseDomain}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${baseDomain}/privkey.pem;
" > "/etc/nginx/ssl/${baseDomain}.conf"
echo "Wrote: /etc/nginx/ssl/${baseDomain}.conf"

touch /var/log/certbot-renew.log
touch /var/log/nginx/access.log
touch /var/log/nginx/error.log

nginx -s reload

crond

tail -F /var/log/nginx/*.log /var/log/certbot-renew.log
