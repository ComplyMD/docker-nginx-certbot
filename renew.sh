#!/bin/sh

certbot \
  renew \
  --renew-hook "nginx -s reload" \
  --keep-until-expiring \
  2>&1 >> /var/log/certbot-renew.log
