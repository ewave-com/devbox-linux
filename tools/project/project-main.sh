#!/usr/bin/env bash

require_once "${devbox_root}/tools/project/dotenv.sh"
require_once "${devbox_root}/tools/project/nginx-reverse-proxy-configs.sh"
require_once "${devbox_root}/tools/project/docker-up-configs.sh"
require_once "${devbox_root}/tools/project/platform-tools.sh"
require_once "${devbox_root}/tools/docker/docker-compose.sh"
require_once "${devbox_root}/tools/docker/docker-sync.sh"
require_once "${devbox_root}/tools/docker/docker.sh"
require_once "${devbox_root}/tools/system/hosts.sh"

############################ Public functions ############################

start_project() {
  dotenv_prepare_project_variables "0"

  create_base_project_dirs

  prepare_project_docker_up_configs
  prepare_project_nginx_reverse_proxy_configs

  docker_sync_start_all_directory_volumes "${project_up_dir}"
  docker_compose_up_all_directory_services "${project_up_dir}" "${project_up_dir}/.env"

  [[ -z "${WEBSITE_EXTRA_HOST_NAMES}" ]] && domains="${WEBSITE_HOST_NAME}" || domains="${WEBSITE_HOST_NAME},${WEBSITE_EXTRA_HOST_NAMES}"
  add_website_domain_to_hosts "${domains}"

  # set 777 permissions for all main project directories
  fix_web_container_permissions

  # Fix for reload network,because devbox-network contains all containers
  sleep 5
  nginx_reverse_proxy_restart
}

stop_project() {
  if [[ ! -d "${project_up_dir}/" || $(find "${project_up_dir}/" -mindepth 1 -maxdepth 1 -name "docker-*.yml" | wc -l) == "0" ]]; then
    return 0
  fi

  dotenv_prepare_project_variables

  docker_compose_down_all_directory_services "${project_up_dir}" "${project_up_dir}/.env"
  docker_sync_stop_all_directory_volumes "${project_up_dir}"

  cleanup_project_nginx_reverse_proxy_configs
  nginx_reverse_proxy_restart

  cleanup_project_docker_up_configs

  [[ -z "${WEBSITE_EXTRA_HOST_NAMES}" ]] && domains="${WEBSITE_HOST_NAME}" || domains="${WEBSITE_HOST_NAME},${WEBSITE_EXTRA_HOST_NAMES}"
  delete_website_domain_from_hosts "${domains}"

  dotenv_unset_variables

  # remove dotenv in the end as it is the main project configuration file
  rm -rf "${project_up_dir}/.env"

  unset selected_project
  unset project_dir
  unset project_up_dir
}

############################ Public functions end ############################

############################ Local functions ############################

init_selected_project() {
  local _selected_project=${1}

  if [ -z "${_selected_project}" ]; then
    show_error_message "Unable to initialize selected project. Name cannot be empty"
    exit 1
  fi

  project_dir="${devbox_projects_dir}/${_selected_project}"
  if [ ! -d "${project_dir}" ]; then
    show_error_message "Selected project directory not found at path ${project_dir}! Please try again with correct choice"
    exit 1
  fi

  if [ ! -f "${project_dir}/.env" ]; then
    show_error_message "File .ENV not found! Please put configuration file exists at path \"${project_dir}/.env\" and try again."
    exit 1
  fi

  project_up_dir="${project_dir}/docker-up"

  export selected_project="${_selected_project}"
  export project_dir
  export project_up_dir

  return 0
}

# 1 - started, 0 - not started
is_project_started() {
  # read project name from the initial file without generating of the final .env
  local _project_name=${1-''}
  if [ -z "${_project_name}" ]; then
    show_error_message "Unable to check if project is started. Project name cannot be empty."
    exit 1
  fi

  local _project_dir="${devbox_projects_dir}/${_selected_project}"
  if [[ ! -d "${_project_dir}" || ! -f "${_project_dir}/.env" ]]; then
    echo "0";
    return
  fi

  _project_name=$(dotenv_get_param_value PROJECT_NAME "${_project_dir}/.env")
  if [[ -z "${_project_name}" ]]; then
    echo "0";
    return
  fi

  local _has_project_running_containers
  _has_project_running_containers=$(is_docker_container_running "${_project_name}_")

  local _project_up_dir="${_project_dir}/docker-up"
  if [[ ! -d "${_project_up_dir}" ]]; then
    echo "0";
    return
  fi

  local _docker_files_count
  _docker_files_count=$(find "${_project_up_dir}/" -mindepth 1 -maxdepth 1 -name "docker-*.yml" | wc -l)

  if [[ -f "${_project_up_dir}/.env" && "${_has_project_running_containers}" == "1" && "${_docker_files_count}" != "0" ]]; then
    echo "1"
  else
    echo "0"
  fi

  return
}

create_base_project_dirs(){
  mkdir -p "${project_up_dir}"

  mkdir -p "${project_dir}/public_html/"
  mkdir -p "${project_dir}/share/"
  mkdir -p "${project_dir}/sysdumps/"

  mkdir -p "${project_dir}/share/composer"
  if [[ ! -f "${project_dir}/share/composer/readme.txt" ]]; then
    echo "This directory will be synced with \"/var/www/.composer\" inside container." > "${project_dir}/share/composer/readme.txt"
    echo "You can put your composer auth.json here if required." > "${project_dir}/share/composer/readme.txt"
  fi

  mkdir -p "${project_dir}/share/ssh"
  if [[ ! -f "${project_dir}/share/ssh/readme.txt" ]]; then
    echo "Content of this directory will be copied into \"/var/www/.ssh\" inside container with permissions updating (see bashrc configs)." > "${project_dir}/share/ssh/readme.txt"
    echo "You can put your ssh keys here if required." > "${project_dir}/share/ssh/readme.txt"
  fi

  mkdir -p "${project_dir}/sysdumps/node_modules/"
  if [[ ${MYSQL_ENABLE} == yes ]]; then
    mkdir -p "${project_dir}/sysdumps/db"
  fi

  if [[ ${ELASTICSEARCH_ENABLE} == yes ]]; then
    mkdir -p "${project_dir}/sysdumps/es"
  fi

  return 0
}

############################ Local functions end ############################
