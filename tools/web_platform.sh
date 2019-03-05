#!/bin/bash
# This function use in add_domain function
nginx_platform(){ 
if [[ -z $CONFIGS_PROVIDER_NGINX ]]; then  
  cp -r ./configs/templates/nginx/default/website.conf.template ./projects/"$project_folder"/configs/nginxconf/$WEBSITE_HOST_NAME.conf
  else  
  cp -r ./configs/templates/nginx/"$CONFIGS_PROVIDER_NGINX"/website.conf.template ./projects/"$project_folder"/configs/nginxconf/$WEBSITE_HOST_NAME.conf
fi
# Add  another custom CONFIGS_PROVIDER_NGINX
#
sed -i 's|%WEBSITE_HOST_NAME%|'$WEBSITE_HOST_NAME'|g'  ./projects/"$project_folder"/configs/nginxconf/$WEBSITE_HOST_NAME.conf
sed -i 's|%WEBSITE_DOCUMENT_ROOT%|'$WEBSITE_DOCUMENT_ROOT'|g' ./projects/"$project_folder"/configs/nginxconf/$WEBSITE_HOST_NAME.conf
}

php_platform(){
if [[ $CONFIGS_PROVIDER_PHP = default ]]; then
  cp -r ./configs/templates/php/default/ini/xdebug.ini ./projects/"$project_folder"/configs/php/xdebug.ini
  cp -r ./configs/templates/php/default/ini/zzz-custom.ini ./projects/"$project_folder"/configs/php/zzz-custom.ini
  sed -i 's|%xdebug_port%|'$xdebug_port'|g' ./projects/"$project_folder"/configs/php/xdebug.ini
fi
}

varnish_platform(){
if [[ $CONFIGS_PROVIDER_VARNISH = magento2 ]]; then
  cp -r ./configs/templates/varnish/magento2/default.vcl.template ./projects/"$project_folder"/configs/varnish/default.vcl
fi
# Add  another custom CONFIGS_PROVIDER_VARNISH
sed -i 's|%PROJECT_NAME%|'$PROJECT_NAME'|g' ./projects/"$project_folder"/configs/varnish/default.vcl
sed -i 's|%CONTAINER_WEB_NAME%|'$CONTAINER_WEB_NAME'|g' ./projects/"$project_folder"/configs/varnish/default.vcl
}

webserver_start(){
if [[ $VARNISH_ENABLE = yes ]]; then
  cp -r ./configs/templates/docker/docker-compose-varnish-nginx-mysql.yml ./projects/"$project_folder"/docker-compose.yml
  #Run funtcion which check varnish template config
  varnish_platform
  else
  cp -r ./configs/templates/docker/docker-compose-nginx-mysql.yml ./projects/"$project_folder"/docker-compose.yml
fi

if [[ $BLACKFIRE_ENABLE = yes ]]; then
  cp -r ./configs/templates/docker/docker-compose-nginx-blackfire-mysql.yml ./projects/"$project_folder"/docker-compose.yml
fi  
}

# Action for enable redis platform.
redis_platform(){
if [[ $REDIS_ENABLE = yes ]]; then
  cp -r ./configs/templates/docker/docker-redis-image.yml ./projects/"$project_folder"/docker-redis-image.yml
  cd ./projects/"$project_folder"/  && sudo docker-compose --log-level "$docker_compose_log_level" -f docker-redis-image.yml up -d > /dev/null 2>&1 
  cd "$devbox_root"
fi
 }

# Action for enable elastic search platform.
es_platform(){
if [[ $ELASTIC_ENABLE = yes ]]; then
  cp -r ./configs/templates/docker/docker-elastic-image.yml ./projects/"$project_folder"/docker-elastic-image.yml
  cd ./projects/"$project_folder"/  && sudo docker-compose --log-level "$docker_compose_log_level" -f docker-elastic-image.yml up -d > /dev/null 2>&1 
  cd "$devbox_root"
fi
}

# Action for enable custom platform.
custom_platform(){
for custom_platform in $( cat ./projects/"$project_folder"/.env | grep CUSTOM_COMPOSE | sed -e 's/.*=//g' );
do
cp -r ./configs/custom/docker/"$custom_platform" ./projects/"$project_folder"/"$custom_platform" ; cd ./projects/"$project_folder"/ ; sudo docker-compose --log-level "$docker_compose_log_level" -f "$custom_platform" up -d ; cd "$devbox_root"
done
}


stop_project () {
# Stop all additionals images
for additional_images_yml in $(ls ./projects/$project_folder/ | grep .yml | awk '{ print $1 }' | grep -v docker-compose.yml);
do
cd ./projects/$project_folder/ && sudo docker-compose --log-level "$docker_compose_log_level" -f $additional_images_yml down > /dev/null 2>&1 && rm -rf $additional_images_yml > /dev/null 2>&1 && cd "$devbox_root"
done
# Stop and remove custom docker-compose.yml
for custom_docker_compose in $( cat ./projects/"$project_folder"/.env | grep CUSTOM_COMPOSE | sed -e 's/.*=//g' );
do
cp -r ./configs/custom/docker/"$custom_docker_compose" ./projects/"$project_folder"/"$custom_docker_compose" ; cd ./projects/"$project_folder"/ ; sudo docker-compose --log-level "$docker_compose_log_level" -f "$custom_docker_compose" down ; rm -rf $custom_docker_compose > /dev/null 2>&1 ; cd "$devbox_root"
done

#Check file and run step if file exist
###
if [ -f ./projects/$project_folder/docker-compose.yml ]; then
  cd ./projects/$project_folder/ && sudo docker-compose --log-level "$docker_compose_log_level" -f docker-compose.yml down && rm -rf docker-compose.yml && cd "$devbox_root"
else
  echo -e  "-------------------------------------------$GREEN SKIP $SET-------------------------------------------------"
  echo -e  "Project $WEBSITE_HOST_NAME is already turned off. Docker-compose.yml in folder $project_folder not found"
  echo -e  "--------------------------------------------------------------------------------------------------\n"

fi
####
#delete nginx project data
devbox_project_folders delete;
#delete nginx reverse data
nginx_reverse_folders delete; 
#delete crt and update CA
sudo rm -rf /usr/local/share/ca-certificates/$WEBSITE_HOST_NAME.crt >/dev/null 2>&1;
sudo update-ca-certificates --fresh > /dev/null 2>&1;
sudo docker network rm devbox_network >/dev/null 2>&1;

sudo -- sh -c -e "cat /etc/hosts | grep $WEBSITE_HOST_NAME | xargs -0  sed -i '/$server_ip $WEBSITE_HOST_NAME/d' /etc/hosts"  >/dev/null 2>&1 ;

echo -e  "--------------------- $GREEN DELETE VHOST FROM HOSTS $SET------------------------"
echo -e "$GREEN Website:$SET http://$WEBSITE_HOST_NAME  was delete form file /etc/hosts"
echo -e  "-----------------------------------------------------------------------\n"
}

# Function for stop all containers [included function stop_project]
stop_all_projects () {
for project_folder in $( ls -Al projects/ | grep "^d" | awk -F" " '{print $9}' );
do
set_env ; stop_project ; unset_env
done

# Stop all additionals images
for env_images_yml in $(ls "$devbox_infra" | grep .yml | awk '{ print $1 }' | grep -v docker-compose.yml);
do
cd "$devbox_infra" && sudo docker-compose --log-level "$docker_compose_log_level" -f $env_images_yml down > /dev/null 2>&1 && cd "$devbox_root"
done

echo -e "---------------------------$GREEN ENV $SET--------------------------------"
echo -e "$GREEN Network devbox_network $SET was deleted"
echo -e "----------------------------------------------------------------\n"
sudo docker network rm devbox_network >/dev/null 2>&1;

echo -e "---------------------------$GREEN ENV $SET--------------------------------"
echo -e "$GREEN DevBox Infrastructure  $SET was stoped"
echo -e "----------------------------------------------------------------\n"
}

