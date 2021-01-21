# vim:set ft=dockerfile:

FROM ubuntu:20.04
MAINTAINER Alex Korotysh <alex.korotysh@ewave.com>

RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common apt-utils apt-transport-https \
    gnupg1 openssl ca-certificates \
    certbot python-certbot-nginx \
    nano curl wget cron \
    nginx 

RUN set -x \
    add-apt-repository -y ppa:certbot/certbot && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y certbot python-certbot-nginx 

RUN rm /etc/nginx/sites-available/default && rm /etc/nginx/sites-enabled/default

#Clear space
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*


EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
