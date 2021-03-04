#!/usr/bin/env bash

############################ Public functions ############################

# set 777 permissions for key directories
function fix_web_container_permissions() {
  docker exec -it "${PROJECT_NAME}_${CONTAINER_WEB_NAME}" /bin/bash -c "/usr/bin/php ${TOOLS_PROVIDER_REMOTE_PATH}/${TOOLS_PROVIDER_ENTRYPOINT} core:setup:permissions && echo"
}

# run platform tools in the end of project starting
function run_platform_tools() {
  # add simple .profile file with sourcing of .bashrc to apply bashrc scripts by first interactive login through docker exec
  docker exec -it -u www-data "${PROJECT_NAME}_${CONTAINER_WEB_NAME}" /bin/bash -c "[[ ! -f ~/.profile ]] && echo '[[ -f ~/.bashrc ]] && . ~/.bashrc' >> ~/.profile"

  docker exec -it -u www-data "${PROJECT_NAME}_${CONTAINER_WEB_NAME}" /bin/bash --login -c "/usr/bin/php ${TOOLS_PROVIDER_REMOTE_PATH}/${TOOLS_PROVIDER_ENTRYPOINT} --autostart"
}

############################ Public functions end ############################
