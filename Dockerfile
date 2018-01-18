FROM nginx:alpine

ENV LETSENCRYPT_PRODUCTION_DIR=/etc/letsencrypt
ENV LETSENCRYPT_STAGING_DIR=/etc/letsencrypt-staging

RUN \
  apk --no-cache add openssl certbot \
  && ( crontab -l 2>/dev/null; echo "0 */12 * * * /renew.sh" ) | crontab - \
  && mkdir -p /etc/nginx/ssl \
  && mkdir -p "${LETSENCRYPT_STAGING_DIR}" \
  && rm /etc/nginx/nginx.conf \
  && rm /etc/nginx/nginx.conf.default \
  && rm /var/log/nginx/access.log \
  && rm /var/log/nginx/error.log \
  && mkdir -p /var/www/certbot_webroot

ADD ./certbot_webroot.conf /etc/nginx/ssl/certbot_webroot.conf
ADD ./renew.sh /renew.sh
ADD ./run.sh /run.sh

CMD [ "/run.sh" ]
