#!/usr/bin/env bash
set -eu

source ./tools/main.sh
source ./tools/install_dependency.sh
source ./tools/devbox_infrastructure.sh
source ./tools/env_file.sh
source ./tools/free_port.sh
source ./tools/web_platform.sh
source ./tools/domain.sh
source ./tools/restart_service.sh
source ./tools/bash_alias.sh
source ./tools/fix_permissions.sh
source ./tools/print_info.sh

ssl_check(){
if [[ -z $WEBSITE_PROTOCOL ]]; then  
request_ssl
else
  if [[ $WEBSITE_PROTOCOL = https ]]; then
  prepare_env ; mysql_free ; ssh_free ; start_infrastructure ; ssl_on
  else
  prepare_env ; mysql_free ; ssh_free ; start_infrastructure ; ssl_off
  fi
fi
}

# Function  which add domain and sed variable
add_domain()(
prepare_add_domain
nginx_platform
php_platform
)

auto_start_addimage()(
redis_platform
es_platform
custom_platform
)

request_ssl(){
while :
  do
  echo "----------------------------------------------"
  echo -e " * * * * * * * $GREEN SSL  option $SET * * * * * * * * "
  echo "----------------------------------------------"
  echo "1)SSL off [prefer]"
  echo "2)SSL on [You will need change base_url in DB]"
  echo "----------------------------------------------"
  echo -n "Enter your menu choice [0-2]:"
  read request_ssl
  case $request_ssl in
    1) prepare_env  ; mysql_free ; ssh_free ; start_infrastructure ; ssl_off ; break ;;
    2) prepare_env  ; mysql_free ; ssh_free ; start_infrastructure ; ssl_on ; break ;;
    *) echo "Opps!!! Please select choice 1 or 2"
       echo "Press a key. . ."
       read -n 1
       ;;
   esac
done
}

docker_architecture(){
    add_domain ; webserver_start ; auto_start_addimage ; sed_ip_port ; start_box
}

run_devbox(){
    ssl_check ; docker_architecture
}

run_platform_tools(){
    sudo docker exec -it "$PROJECT_NAME"_"$CONTAINER_WEB_NAME" /bin/bash -c "/usr/bin/php $TOOLS_PROVIDER_REMOTE_PATH/$TOOLS_PROVIDER_ENTRYPOINT --autostart"
}

# Check and install docker
install_docker
# Check and install composer
install_composer

# Select folder with project
list_projects

# Immediately run fucntion
set_env

# Check status project's containers
count_up_project_containers

# Run devbox
run_devbox

#final restart
nginx_reverse_proxy_restart

# Fix Permissions
fix_permissions

# Add Tools Alias
addToolsAlias

# Print project info
print_info

# Run platform tools
run_platform_tools

#Unset
unset_env
