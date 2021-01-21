FROM madebyewave/php54-fpm
MAINTAINER Alex Korotysh <alex.korotysh@ewave.com >
ENV PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data"

ADD ./config/ssmtp.conf /etc/ssmtp/ssmtp.conf
ADD ./config/supervisord.conf /etc/supervisord.conf
RUN mkdir /var/log/php5-fpm/ /run/php/ /var/run/sshd

#Remove old deb repository
RUN rm -rf  /etc/apt/sources.list.d/ondrej-php5-oldstable-precise.list

# Intall packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common apt-utils apt-transport-https && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ssmtp \
    git \
    mailutils mc inetutils-ping unzip bzip2 libpng-dev net-tools openssh-server supervisor nano curl sudo mysql-client nginx htop vim build-essential make dnsutils

# prepare directories & permissions for project
RUN echo 'www-data:www-data' | chpasswd \
    && echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && mkdir -p /home/www-data/public_html \
    && mkdir -p /home/www-data/state \
    && chown -R www-data:www-data /home/www-data \
    && mkdir -p /var/www/public_html \
    && chown -R www-data:www-data /var/www

# www.conf
RUN sed -i 's/listen\s*=.*/listen = 0.0.0.0:9000/g' /etc/php5/fpm/pool.d/www.conf
# PHP options
RUN sed -i 's/memory_limit\s*=.*/memory_limit=2048M/g' /etc/php5/cli/php.ini
RUN sed -i 's/memory_limit\s*=.*/memory_limit=2048M/g' /etc/php5/fpm/php.ini
RUN sed -i 's/max_execution_time\s*=.*/max_execution_time=3600/g' /etc/php5/fpm/php.ini
RUN sed -i 's/max_execution_time\s*=.*/max_execution_time=3600/g' /etc/php5/cli/php.ini
RUN sed -i 's/max_input_time\s*=.*/max_input_time=1200/g' /etc/php5/fpm/php.ini
RUN sed -i 's/max_input_time\s*=.*/max_input_time=1200/g' /etc/php5/cli/php.ini
RUN sed -i 's/max_input_vars\s*=.*/max_input_vars=30000/g' /etc/php5/fpm/php.ini
RUN sed -i 's/max_input_vars\s*=.*/max_input_vars=30000/g' /etc/php5/cli/php.ini
RUN sed -i 's/max_file_uploads\s*=.*/max_file_uploads=1000/g' /etc/php5/fpm/php.ini
RUN sed -i 's/max_file_uploads\s*=.*/max_file_uploads=1000/g' /etc/php5/cli/php.ini
RUN sed -i 's/default_socket_timeout\s*=.*/default_socket_timeout=1200/g' /etc/php5/cli/php.ini
RUN sed -i 's/default_socket_timeout\s*=.*/default_socket_timeout=1200/g' /etc/php5/fpm/php.ini
RUN sed -i 's/upload_max_filesize\s*=.*/upload_max_filesize=512M/g' /etc/php5/cli/php.ini
RUN sed -i 's/upload_max_filesize\s*=.*/upload_max_filesize=512M/g' /etc/php5/fpm/php.ini
RUN sed -i 's/post_max_size\s*=.*/post_max_size=512M/g' /etc/php5/cli/php.ini
RUN sed -i 's/post_max_size\s*=.*/post_max_size=512M/g' /etc/php5/fpm/php.ini

#Fix
RUN sudo ln -sfn /usr/bin/php5 /usr/bin/php

ADD ./config/ssmtp.conf /etc/ssmtp/ssmtp.conf
ADD ./config/supervisord.conf /etc/supervisord.conf
RUN sed -i 's|%$PHP_VERSION%|'$PHP_VERSION'|g'  /etc/supervisord.conf

RUN rm /etc/nginx/sites-available/default && rm /etc/nginx/sites-enabled/default

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer

RUN echo 'www-data:hugTeybvootduc' | chpasswd && usermod -s /bin/bash www-data
RUN echo "sudo -H -u www-data -s" >> /root/.bashrc

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

RUN mkdir -p /var/www && chown www-data:www-data /var/www/ && usermod -a -G sudo www-data
RUN echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# unison: copy config & sh files
ADD config/entrypoint.sh /usr/local/bin/entrypoint.sh

# Copy unison 
COPY ./config/unison_linux/unison /usr/local/bin/unison
COPY ./config/unison_linux/unison-fsmonitor /usr/local/bin/unison-fsmonitor

# Copy bashrc
COPY ./config/.bashrc_root /root/.bashrc
COPY ./config/.bashrc_www-data /var/www/.bashrc

# Execution permission
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/unison \
    && chmod +x /usr/local/bin/unison-fsmonitor 

# Fix slow ubuntu repoRUN sed -i 's/mirror.datacenter.by/archive.ubuntu.com/g' /etc/apt/sources.list
#RUN sed -i 's/mirror.datacenter.by/archive.ubuntu.com/g' /etc/apt/sources.list

RUN echo "Host *" >> /etc/ssh/ssh_config
RUN echo "ForwardAgent yes" >> /etc/ssh/ssh_config
RUN echo "HashKnownHosts no" >> /etc/ssh/ssh_config
RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# git config
RUN git config --add --global core.fileMode false && git config --add --global core.autocrlf input && git config --add --global core.eol lf
RUN su - www-data -c 'git config --add --global core.fileMode false && git config --add --global core.autocrlf input && git config --add --global core.eol lf'

# cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/
USER root

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]