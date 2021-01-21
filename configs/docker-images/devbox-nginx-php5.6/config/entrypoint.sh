#!/usr/bin/env bash
rm -rf /var/www/public_html/status.html
rm -rf /home/www-data/public_html/status.html

if [ $USE_UNISON_SYNC == "1" ]
then
    su - www-data -c '/usr/local/bin/unison -socket 5000 2>&1 >/dev/null' &
fi

supervisord -n -c /etc/supervisord.conf

git config --global core.fileMode false
git config --global core.autocrlf input
git config --global core.eol lf