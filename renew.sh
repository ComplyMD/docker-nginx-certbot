#!/bin/sh

certbot \
  renew \
  --renew-hook "nginx -s reload" \
  2>&1 >> /var/log/certbot-renew.log
