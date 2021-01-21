#!/usr/bin/env bash

############################ Public functions ############################

#add_platform_tools_bashrc_alias() {
#  sudo docker exec -it "${PROJECT_NAME}"_"${CONTAINER_WEB_NAME}" /bin/bash -c "echo 'alias platform-tools='\'/usr/bin/php ${TOOLS_PROVIDER_REMOTE_PATH}/${TOOLS_PROVIDER_ENTRYPOINT}\''' >> ~/.bashrc"
#  sudo docker exec -it "${PROJECT_NAME}"_"${CONTAINER_WEB_NAME}" /bin/bash -c "echo 'alias platform-tools='\'/usr/bin/php ${TOOLS_PROVIDER_REMOTE_PATH}/${TOOLS_PROVIDER_ENTRYPOINT}\''' >> /var/www/.bashrc && chown -R www-data:www-data /var/www/.bashrc"
#}

# set 777 permissions for key directories
fix_web_container_permissions() {
  sudo docker exec -it "${PROJECT_NAME}"_"${CONTAINER_WEB_NAME}" /bin/bash -c "/usr/bin/php ${TOOLS_PROVIDER_REMOTE_PATH}/${TOOLS_PROVIDER_ENTRYPOINT} core:setup:permissions && echo"
}

# run platform tools in the end of project starting
run_platform_tools() {
  sudo docker exec -it "${PROJECT_NAME}"_"${CONTAINER_WEB_NAME}" /bin/bash -c "/usr/bin/php "${TOOLS_PROVIDER_REMOTE_PATH}/${TOOLS_PROVIDER_ENTRYPOINT}" --autostart"
}

############################ Public functions end ############################
