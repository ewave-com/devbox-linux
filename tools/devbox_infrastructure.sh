#!/bin/bash
# Function which start nginx,portainer,mailhog
start_infrastructure(){
network_check=$(sudo docker network ls --filter NAME=devbox_network | grep devbox_network | awk '{print $2}' )	

if [[ -z "$network_check" ]]; then
sudo docker network create devbox_network
fi
echo -e "---------------------------$GREEN ENV $SET--------------------------------"
echo -e "$GREEN Network devbox_network $SET was created"
echo -e "----------------------------------------------------------------\n"


export $(cat "$devbox_infra"/.env | grep -Ev "^$" | grep -v '^#' | xargs)
cd "$devbox_infra"
sudo docker-compose --log-level "$docker_compose_log_level" -f docker-compose-portainer.yml up -d
sudo docker-compose --log-level "$docker_compose_log_level" -f docker-compose-nginx-reverse-proxy.yml up -d

if [[ $MAILER_TYPE = mailhog ]]; then
  sudo docker-compose --log-level "$docker_compose_log_level" -f docker-compose-mailhog.yml up -d > /dev/null 2>&1
fi
if [[ $MAILER_TYPE = exim4 ]]; then
  sudo docker-compose --log-level "$docker_compose_log_level" -f docker-compose-exim4.yml up -d > /dev/null 2>&1
fi
if [[ $ADMINER_ENABLE = yes ]]; then
  sudo docker-compose --log-level "$docker_compose_log_level" -f docker-compose-adminer.yml up -d > /dev/null 2>&1
fi
cd "$devbox_root"
unset $(cat "$devbox_infra"/.env | grep -Ev "^$"  | grep -v '^#' | sed -E 's/(.*)=.*/\1/' | xargs)

echo -e "---------------------------$GREEN ENV $SET--------------------------------"
echo -e "$GREEN DevBox Infrastructure  $SET was created"
echo -e "----------------------------------------------------------------\n"

}

nginx_reverse_folders () {
if [[ $1 = create ]]; then
  mkdir -p "$devbox_infra"/nginx/conf.d/
  mkdir -p "$devbox_infra"/nginx/ssl/
  mkdir -p "$devbox_infra"/nginx/logs/
fi
if [[ $1 = delete ]]; then
  rm -rf "$devbox_infra"/nginx/conf.d/"$WEBSITE_HOST_NAME".conf >/dev/null 2>&1;
  rm -rf "$devbox_infra"/nginx/ssl/"$WEBSITE_HOST_NAME".conf >/dev/null 2>&1;
  rm -rf "$devbox_infra"/nginx/logs/"$WEBSITE_HOST_NAME"* >/dev/null 2>&1;
fi
}

ssl_on(){
nginx_reverse_folders create 
sudo su -c "openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name secp384r1) -keyout $devbox_infra/nginx/ssl/$WEBSITE_HOST_NAME.key -out $devbox_infra/nginx/ssl/$WEBSITE_HOST_NAME.crt -days 365 -subj "/C=BY/ST=Minsk/L=Minsk/O=DevOpsTeam_EWave/CN=$WEBSITE_HOST_NAME"" > /dev/null 2>&1
cp -r ./configs/templates/nginx/reverse-proxy/nginx-https-proxy.conf.template "$devbox_infra"/nginx/conf.d/$WEBSITE_HOST_NAME.conf
sudo cp -r "$devbox_infra"/nginx/ssl/"$WEBSITE_HOST_NAME".crt /usr/local/share/ca-certificates/"$WEBSITE_HOST_NAME".crt
sudo update-ca-certificates > /dev/null 2>&1
}

ssl_off(){
nginx_reverse_folders create 
cp -r ./configs/templates/nginx/reverse-proxy/nginx-http-proxy.conf.template "$devbox_infra"/nginx/conf.d/$WEBSITE_HOST_NAME.conf
}

start_box(){
cd ./projects/"$project_folder"/ && sudo docker-compose --log-level "$docker_compose_log_level" -f docker-compose.yml up -d 
cd "$devbox_root"
}


