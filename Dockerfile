FROM nginx:alpine

RUN \
  apk --no-cache add openssl certbot \
  && ( crontab -l 2>/dev/null; echo "0 */12 * * * /renew.sh" ) | crontab - \
  && mkdir -p /etc/nginx/ssl \
  && rm /etc/nginx/nginx.conf \
  && rm /etc/nginx/nginx.conf.default \
  && rm /var/log/nginx/access.log \
  && rm /var/log/nginx/error.log \
  && mkdir -p /var/www/certbot_webroot

ADD ./certbot_webroot.conf /etc/nginx/ssl/certbot_webroot.conf
ADD ./renew.sh /renew.sh
ADD ./run.sh /run.sh

CMD [ "/run.sh" ]
