#!/usr/bin/env bash

export devbox_root
export devbox_infra_dir="${devbox_root}/configs/infrastructure"
export devbox_projects_dir="${devbox_root}/projects"
export dotenv_defaults_filepath="${devbox_root}/configs/project-defaults.env"
export dotenv_infra_filepath="${devbox_root}/configs/infrastructure/infra.env"
export current_env_filepath=""

export host_user=${USER}
export host_user_group=$(id -g -n)

export docker_compose_log_level=ERROR

# update devbox vendor packages automatically (monthly)
export composer_autoupdate="1"

# update stored docker images with ':latest' tag automatically (monthly)
export docker_images_autoupdate="1"
# coma-separated list on skipped images to be refreshed automatically (e.g. from private storages)
export docker_images_autoupdate_skip_images=""

##################################################################################

function get_os_type() {
  local _os_type

  if [[ "${OSTYPE}" == "linux-gnu"* ]]; then
    _os_type="linux"
  elif [[ "${OSTYPE}" == "darwin"* ]]; then
    _os_type="macos"
  else
    _os_type="os not recognized"
  fi

  echo "${_os_type}"
}

export os_type=$(get_os_type)

# Set color variable
#DARKGRAY='\033[1;30m'
RED='\033[0;31m'
#LIGHTRED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
#PURPLE='\033[0;35m'
#LIGHTPURPLE='\033[1;35m'
#CYAN='\033[0;36m'
WHITE='\033[1;37m'
SET='\033[0m'
#########################

# if you need to override any parameters from this file, just create the file "${devbox_root}/constants-override.sh" and put required params there
# variables will be overloaded
if [[ -f "${devbox_root}/constants-override.sh" ]]; then
  require_one "${devbox_root}/constants-override.sh"
fi
