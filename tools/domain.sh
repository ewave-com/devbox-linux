#!/bin/bash

devbox_project_folders () {
if [[ $1 = create ]]; then
  mkdir -p ./projects/"$project_folder"/configs/nginxconf/
  mkdir -p ./projects/"$project_folder"/configs/nginxlogs/
  mkdir -p ./projects/"$project_folder"/configs/varnish/
  mkdir -p ./projects/"$project_folder"/configs/cron/
  mkdir -p ./projects/"$project_folder"/configs/php/
  mkdir -p ./projects/"$project_folder"/configs/node_modules/
  mkdir -p ./projects/"$project_folder"/dumps/db
  mkdir -p ./projects/"$project_folder"/dumps/media
  mkdir -p ./projects/"$project_folder"/dumps/configs
  mkdir -p ./projects/"$project_folder"/db
  mkdir -p ./projects/"$project_folder"/es
  mkdir -p ./projects/"$project_folder"/public_html/
fi
if [[ $1 = delete ]]; then
  rm -rf ./projects/"$project_folder"/configs/nginxconf/ >/dev/null 2>&1;
  rm -rf ./projects/"$project_folder"/configs/nginxlogs/ >/dev/null 2>&1;
  rm -rf ./projects/"$project_folder"/configs/varnish/ >/dev/null 2>&1;
  rm -rf ./projects/"$project_folder"/configs/cron/ >/dev/null 2>&1;
  rm -rf ./projects/"$project_folder"/configs/php/ >/dev/null 2>&1;
fi
}

prepare_add_domain (){
# Sed variable,after created conf in SSL_on/SSL_off  
sed -i 's|%WEBSITE_HOST_NAME%|'$WEBSITE_HOST_NAME'|g' "$devbox_infra"/nginx/conf.d/$WEBSITE_HOST_NAME.conf
sed -i 's|%WEBSITE_DOCUMENT_ROOT%|'$WEBSITE_DOCUMENT_ROOT'|g' "$devbox_infra"/nginx/conf.d/$WEBSITE_HOST_NAME.conf
sed -i 's|%PROJECT_NAME%|'$PROJECT_NAME'|g' "$devbox_infra"/nginx/conf.d/$WEBSITE_HOST_NAME.conf

if [[ $VARNISH_ENABLE = yes ]]; then
  sed -i 's|%CONTAINER_WEB_NAME%|'$CONTAINER_VARNISH_NAME'|g' "$devbox_infra"/nginx/conf.d/$WEBSITE_HOST_NAME.conf
  else
  sed -i 's|%CONTAINER_WEB_NAME%|'$CONTAINER_WEB_NAME'|g' "$devbox_infra"/nginx/conf.d/$WEBSITE_HOST_NAME.conf
fi
#sudo docker exec -ti nginx-reverse-proxy bash -c "service nginx restart"
# Add site to file hosts
sudo -- sh -c -e "echo '127.0.0.1 $WEBSITE_HOST_NAME' >> /etc/hosts";
# mkdir folders#
devbox_project_folders create
}
