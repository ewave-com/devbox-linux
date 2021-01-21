FROM madebyewave/nginx-php7.4
MAINTAINER Alex Korotysh < alex.lkorotysh@ewave.com >
ENV PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data"
ENV PHP_VERSION="7.4"

#install blackfire profiler
ENV PHP_INI_DIR="/etc/php/$PHP_VERSION/fpm"
# Temp disable
#RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
#    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
#    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
#    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
#    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini

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

#Fix yarn key
RUN wget -qO - https://raw.githubusercontent.com/yarnpkg/releases/gh-pages/debian/pubkey.gpg | sudo apt-key add -

# APT: install
RUN apt-get update && apt-get install -y \
    apt-utils php-xdebug 

# php config
COPY config/php/ini/xdebug.ini /etc/php/$PHP_VERSION/mods-available/xdebug.ini
COPY config/php/ini/zzz-custom.ini /etc/php/$PHP_VERSION/mods-available/zzz-custom.ini
RUN ln -sf /etc/php/$PHP_VERSION/mods-available/zzz-custom.ini /etc/php/$PHP_VERSION/cli/conf.d/99-zzz-custom.ini \
    && ln -sf /etc/php/$PHP_VERSION/mods-available/zzz-custom.ini /etc/php/$PHP_VERSION/fpm/conf.d/99-zzz-custom.ini \
    && rm -f /etc/php/$PHP_VERSION/cli/conf.d/20-xdebug.ini

# git config
RUN git config --add --global core.fileMode false && git config --add --global core.autocrlf input && git config --add --global core.eol lf
RUN su - www-data -c 'git config --add --global core.fileMode false && git config --add --global core.autocrlf input && git config --add --global core.eol lf'

ADD config/php/www.conf /etc/php/$PHP_VERSION/fpm/pool.d/www.conf

# cleanup
RUN sudo apt-get clean
RUN rm -rf /var/lib/apt/list/*

WORKDIR /var/www/

USER root

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
