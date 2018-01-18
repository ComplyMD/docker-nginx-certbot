#!/bin/sh

set -eou pipefail

openssl dhparam -out /etc/nginx/ssl/dhparams.pem 2048

baseDomain=$(echo "${DOMAINS}" | cut -f1 -d",")

touch "/etc/nginx/ssl/${baseDomain}.conf"
echo "Stubbed: /etc/nginx/ssl/${baseDomain}.conf"

nginx

CERTBOT_STAGING="${CERTBOT_STAGING:-"false"}"
certificateDir="${LETSENCRYPT_PRODUCTION_DIR}"
if [ $CERTBOT_STAGING = "true" ] || [ $CERTBOT_STAGING = "yes" ] ; then
  certificateDir="${LETSENCRYPT_STAGING_DIR}"
  echo "Creating staging certificates: ${certificateDir}"
  certbot \
    certonly \
    --webroot \
    --webroot-path /var/www/certbot_webroot \
    --domains "${DOMAINS}" \
    --agree-tos \
    --email engineering@vincari.com \
    --noninteractive \
    --staging \
    --config-dir "${certificateDir}"
else
  echo "Creating production certificates"
  certbot \
    certonly \
    --webroot \
    --webroot-path /var/www/certbot_webroot \
    --domains "${DOMAINS}" \
    --expand \
    --agree-tos \
    --email engineering@vincari.com \
    --noninteractive
fi

echo -e "
  ssl_certificate ${certificateDir}/live/${baseDomain}/fullchain.pem;
  ssl_certificate_key ${certificateDir}/live/${baseDomain}/privkey.pem;
" > "/etc/nginx/ssl/${baseDomain}.conf"
echo "Wrote: /etc/nginx/ssl/${baseDomain}.conf"

touch /var/log/certbot-renew.log
touch /var/log/nginx/access.log
touch /var/log/nginx/error.log

nginx -s reload

crond

tail -F /var/log/nginx/*.log /var/log/certbot-renew.log
