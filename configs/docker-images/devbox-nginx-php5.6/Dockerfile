FROM madebyewave/nginx-php5.6
MAINTAINER Alex Korotysh <alex.korotysh@ewave.com >
ENV PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data"

#install blackfire profiler
ENV PHP_INI_DIR="/etc/php/5.6/fpm"
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini

# nginx: remove default config and enable our magento config
RUN rm -rf /etc/nginx/sites-available/default \
    && rm -rf /etc/nginx/sites-enabled/default 

# prepare directories & permissions for project
RUN echo 'www-data:www-data' | chpasswd \
    && echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && mkdir -p /home/www-data/public_html \
    && mkdir -p /home/www-data/state \
    && chown -R www-data:www-data /home/www-data \
    && mkdir -p /var/www/public_html \
    && chown -R www-data:www-data /var/www

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

# APT: install
RUN apt-get update && apt-get install -y \
    apt-utils php-xdebug 

# php config
COPY config/php/ini/xdebug.ini /etc/php/5.6/mods-available/xdebug.ini
COPY config/php/ini/zzz-custom.ini /etc/php/5.6/mods-available/zzz-custom.ini
RUN ln -sf /etc/php/5.6/mods-available/zzz-custom.ini /etc/php/5.6/cli/conf.d/99-zzz-custom.ini \
    && ln -sf /etc/php/5.6/mods-available/zzz-custom.ini /etc/php/5.6/fpm/conf.d/99-zzz-custom.ini \
    && rm -f /etc/php/5.6/cli/conf.d/20-xdebug.ini

# git config
RUN git config --add --global core.fileMode false && git config --add --global core.autocrlf input && git config --add --global core.eol lf
RUN su - www-data -c 'git config --add --global core.fileMode false && git config --add --global core.autocrlf input && git config --add --global core.eol lf'

#PHP setting
ADD config/php/www.conf /etc/php/5.6/fpm/pool.d/www.conf
RUN sed -i 's/memory_limit\s*=.*/memory_limit=2048M/g' /etc/php/5.6/cli/php.ini
RUN sed -i 's/memory_limit\s*=.*/memory_limit=2048M/g' /etc/php/5.6/fpm/php.ini
RUN sed -i 's/max_execution_time\s*=.*/max_execution_time=1200/g' /etc/php/5.6/fpm/php.ini
RUN sed -i 's/max_execution_time\s*=.*/max_execution_time=1200/g' /etc/php/5.6/cli/php.ini
RUN sed -i 's/default_socket_timeout\s*=.*/default_socket_timeout=1200/g' /etc/php/5.6/cli/php.ini
RUN sed -i 's/default_socket_timeout\s*=.*/default_socket_timeout=1200/g' /etc/php/5.6/fpm/php.ini
RUN sed -i 's/upload_max_filesize\s*=.*/upload_max_filesize=512M/g' /etc/php/5.6/cli/php.ini
RUN sed -i 's/upload_max_filesize\s*=.*/upload_max_filesize=512M/g' /etc/php/5.6/fpm/php.ini
RUN sed -i 's/post_max_size\s*=.*/post_max_size=512M/g' /etc/php/5.6/cli/php.ini
RUN sed -i 's/post_max_size\s*=.*/post_max_size=512M/g' /etc/php/5.6/fpm/php.ini
RUN sudo ln -sfn /usr/bin/php5.6 /usr/bin/php

# cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/
USER root

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]