#!/usr/bin/env bash

require_once "${devbox_root}/tools/project/project-dotenv.sh"
require_once "${devbox_root}/tools/project/nginx-reverse-proxy-configs.sh"
require_once "${devbox_root}/tools/project/docker-up-configs.sh"
require_once "${devbox_root}/tools/project/platform-tools.sh"
require_once "${devbox_root}/tools/project/project-state.sh"
require_once "${devbox_root}/tools/docker/docker-compose.sh"
require_once "${devbox_root}/tools/docker/docker-sync.sh"
require_once "${devbox_root}/tools/docker/docker.sh"
require_once "${devbox_root}/tools/system/dotenv.sh"
require_once "${devbox_root}/tools/system/hosts.sh"
require_once "${devbox_root}/tools/system/file.sh"

############################ Public functions ############################

function start_project() {
  # fast strategy is available after project stopping
  local _is_simplified_start_available=$(is_simplified_start_available)

  if [[ "${_is_simplified_start_available}" == "0" ]]; then
    show_success_message "Start project using full strategy." "1"
  else
    show_success_message "Start project using simplified strategy." "1"
  fi

  if [[ "${_is_simplified_start_available}" == "0" ]]; then
    set_state_last_project_status "starting"

    show_success_message "Generating project file .env and variables" "2"
    prepare_project_dotenv_variables "1"

    show_success_message "Creating missing project directories" "2"
    create_base_project_dirs

    show_success_message "Preparing required project docker-up configs" "2"
    prepare_project_docker_up_configs
  else
    prepare_project_dotenv_variables "0"

    ensure_exposed_container_ports_are_available "${project_up_dir}/.env"

    set_state_last_project_status "starting"
  fi

  show_success_message "Preparing nginx-reverse-proxy configs" "2"
  prepare_project_nginx_reverse_proxy_configs

  show_success_message "Starting data synchronization" "2"
  docker_sync_start_all_directory_volumes "${project_up_dir}"

  show_success_message "Starting project docker container" "2"
  docker_compose_up_all_directory_services "${project_up_dir}" "${project_up_dir}/.env"

  if [[ "${_is_simplified_start_available}" == "0" ]]; then
    show_success_message "Adding domains to hosts file" "2"
    [[ -z "${WEBSITE_EXTRA_HOST_NAMES}" ]] && domains="${WEBSITE_HOST_NAME}" || domains="${WEBSITE_HOST_NAME},${WEBSITE_EXTRA_HOST_NAMES}"
    add_website_domain_to_hosts "${domains}"
  fi

  # Fix for reload network,because devbox-network contains all containers
  sleep 5
  show_success_message "Restarting nginx-reverse-proxy" "2"
  nginx_reverse_proxy_restart

  if [[ "${os_type}" == "linux" ]]; then
    show_success_message "Expanding web container permissions" "2"
    fix_web_container_permissions
  fi

  set_state_dotenv_hash
  set_state_last_project_status "started"
}

function stop_current_project() {
  if [[ ! -d "${project_up_dir}/" || $(find "${project_up_dir}/" -mindepth 1 -maxdepth 1 -name "docker-*.yml" | wc -l) == "0" ]]; then
    return 0
  fi

  set_state_last_project_status "stopping"

  show_success_message "Preparing project variables from .env" "2"
  prepare_project_dotenv_variables

  show_success_message "Stopping project docker containers" "2"
  docker_compose_stop_all_directory_services "${project_up_dir}" "${project_up_dir}/.env"
  #  docker_compose_down_all_directory_services "${project_up_dir}" "${project_up_dir}/.env"

  show_success_message "Stopping data syncing" "2"
  docker_sync_stop_all_directory_volumes "${project_up_dir}"

  show_success_message "Cleaning nginx-reverse-proxy configs" "2"
  cleanup_project_nginx_reverse_proxy_configs

  if [[ "$(is_docker_container_running 'nginx-reverse-proxy')" == "1" ]]; then
    show_success_message "Restarting nginx-reverse-proxy" "2"
    nginx_reverse_proxy_restart
  fi

  dotenv_unset_variables "${project_up_dir}/.env"

  set_state_last_project_status "stopped"

  unset selected_project
  unset project_dir
  unset project_up_dir
}

function down_current_project() {
  show_success_message "Preparing project variables from .env" "2"
  prepare_project_dotenv_variables

  if [[ -n "$(ls "${project_up_dir}" | grep "docker-compose-.*.yml")" ]]; then
    show_success_message "Downing docker containers" "2"
    docker_compose_down_all_directory_services "${project_up_dir}" "${project_up_dir}/.env"
  fi

  if [[ -n "$(ls "${project_up_dir}" | grep "docker-sync-.*.yml")" ]]; then
    show_success_message "Stopping data syncing" "2"
    docker_sync_stop_all_directory_volumes "${project_up_dir}"
  fi

  show_success_message "Cleaning nginx-reverse-proxy configs" "2"
  cleanup_project_nginx_reverse_proxy_configs

  if [[ "$(is_docker_container_running 'nginx-reverse-proxy')" == "1" ]]; then
    show_success_message "Restarting nginx-reverse-proxy" "2"
    nginx_reverse_proxy_restart
  fi

  show_success_message "Cleaning project docker-up configs" "2"
  cleanup_project_docker_up_configs

  show_success_message "Removing domains from hosts file" "2"
  [[ -z "${WEBSITE_EXTRA_HOST_NAMES+x}" ]] && domains="${WEBSITE_HOST_NAME}" || domains="${WEBSITE_HOST_NAME},${WEBSITE_EXTRA_HOST_NAMES}"
  delete_website_domain_from_hosts "${domains}"

  dotenv_unset_variables "${project_up_dir}/.env"

  show_success_message "Deleting generated .env file" "2"
  # remove dotenv in the end as it is the main project configuration file
  rm -rf "${project_up_dir}/.env"

  unset selected_project
  unset project_dir
  unset project_up_dir
}

function down_and_clean_current_project() {
  show_success_message "Preparing project variables from .env" "2"
  prepare_project_dotenv_variables

  if [[ -n "$(ls "${project_up_dir}" | grep "docker-compose-.*.yml")" ]]; then
    show_success_message "Downing docker containers and removing volumes" "2"
    docker_compose_down_and_clean_all_directory_services "${project_up_dir}" "${project_up_dir}/.env"
  fi

  if [[ -n "$(ls "${project_up_dir}" | grep "docker-sync-.*.yml")" ]]; then
    show_success_message "Stopping data syncing" "2"
    docker_sync_stop_all_directory_volumes "${project_up_dir}"

    show_success_message "Cleaning sync volumes" "2"
    docker_sync_clean_all_directory_volumes "${project_up_dir}"
  fi

  show_success_message "Cleaning nginx-reverse-proxy configs" "2"
  cleanup_project_nginx_reverse_proxy_configs

  if [[ "$(is_docker_container_running 'nginx-reverse-proxy')" == "1" ]]; then
    show_success_message "Restarting nginx-reverse-proxy" "2"
    nginx_reverse_proxy_restart
  fi

  show_success_message "Cleaning project docker-up configs" "2"
  cleanup_project_docker_up_configs

  show_success_message "Removing domains from hosts file" "2"
  [[ -z "${WEBSITE_EXTRA_HOST_NAMES+x}" ]] && domains="${WEBSITE_HOST_NAME}" || domains="${WEBSITE_HOST_NAME},${WEBSITE_EXTRA_HOST_NAMES}"
  delete_website_domain_from_hosts "${domains}"

  dotenv_unset_variables "${project_up_dir}/.env"

  show_success_message "Deleting generated .env file" "2"
  # remove dotenv in the end as it is the main project configuration file
  rm -rf "${project_up_dir}/.env"

  unset selected_project
  unset project_dir
  unset project_up_dir
}

############################ Public functions end ############################

############################ Local functions ############################

function init_selected_project() {
  local _selected_project=${1}

  if [ -z "${_selected_project}" ]; then
    show_error_message "Unable to initialize selected project. Name cannot be empty"
    exit 1
  fi

  ensure_project_configured "${_selected_project}"

  project_dir="${devbox_projects_dir}/${_selected_project}"
  project_up_dir="${project_dir}/docker-up"

  export selected_project="${_selected_project}"
  export project_dir
  export project_up_dir
}

function is_simplified_start_available() {
    if [[ "$(is_state_file_exists)" == "0" ]]; then
      echo "0"
      return
    fi

    local _last_project_status
    _last_project_status="$(get_state_last_project_status)"
    if [[ "${_last_project_status}" != "stopped" ]]; then
      echo "0"
      return
    fi

    local _current_dotenv_hash
    _current_dotenv_hash="$(get_file_md5_hash "${project_dir}/.env")"

    local _stored_dotenv_hash
    _stored_dotenv_hash=$(state_get_param_value "dotenv_hash")
    if [[ "${_current_dotenv_hash}" != "${_stored_dotenv_hash}" ]]; then
      echo "0"
      return
    fi

    echo "1"
}

function create_base_project_dirs() {
  if [[ ! -d "${project_up_dir}" ]]; then
    mkdir -p "${project_up_dir}"
  fi

  if [[ ! -d "${project_dir}/public_html/" ]]; then
    mkdir -p "${project_dir}/public_html/" && sudo chmod -R 777 "${project_dir}/public_html"
  fi
  if [[ "${os_type}" == "linux" && -z $(getfacl --absolute-names "${project_dir}/public_html" | grep "default:other::rw") ]]; then
    sudo setfacl --default --recursive -m u::rwx,g::rwx,o:rwx "${project_dir}/public_html"
  fi

  if [[ ! -d "${project_dir}/share/" ]]; then
    mkdir -p "${project_dir}/share/" && sudo chmod -R 777 "${project_dir}/share"
  fi
  if [[ "${os_type}" == "linux" && -z $(getfacl --absolute-names "${project_dir}/share" | grep "default:other::rw") ]]; then
    sudo setfacl --default --recursive -m u::rwx,g::rwx,o:rwx "${project_dir}/share"
  fi

  if [[ ! -d "${project_dir}/sysdumps/" ]]; then
    mkdir -p "${project_dir}/sysdumps/" && sudo chmod -R 777 "${project_dir}/sysdumps"
  fi
  if [[ "${os_type}" == "linux" && -z $(getfacl --absolute-names "${project_dir}/sysdumps" | grep "default:other::rw") ]]; then
    sudo setfacl --default --recursive -m u::rwx,g::rwx,o:rwx "${project_dir}/sysdumps"
  fi

  if [[ ! -d "${project_dir}/share/composer" ]]; then
    mkdir -p "${project_dir}/share/composer" && sudo chmod -R 777 "${project_dir}/share/composer"
  fi
  if [[ ! -f "${project_dir}/share/composer/readme.txt" ]]; then
    echo "This directory content will be copied into '/var/www/.composer' inside container (see bashrc configs bashrc_www-data)." >"${project_dir}/share/composer/readme.txt"
    echo "You can put your composer auth.json here if required." >"${project_dir}/share/composer/readme.txt"
  fi

  if [[ ! -d "${project_dir}/share/ssh" ]]; then
    mkdir -p "${project_dir}/share/ssh" && sudo chmod -R 777 "${project_dir}/share/ssh"
  fi
  if [[ ! -f "${project_dir}/share/ssh/readme.txt" ]]; then
    echo "Content of this directory will be copied into '/var/www/.ssh' inside container with permissions updating (see bashrc configs bashrc_www-data)." >"${project_dir}/share/ssh/readme.txt"
    echo "You can put your ssh keys here if required." >"${project_dir}/share/ssh/readme.txt"
  fi

  if [[ ! -d "${project_dir}/sysdumps/node_modules/" ]]; then
    mkdir -p "${project_dir}/sysdumps/node_modules/" && sudo chmod -R 777 "${project_dir}/sysdumps/node_modules/"
  fi

  if [[ -n "${COMPOSER_CACHE_DIR}" && ! -d "${COMPOSER_CACHE_DIR}" ]]; then
    sudo mkdir -p "${COMPOSER_CACHE_DIR}"
    sudo chown -R "${host_user}":"${host_user_group}" "${COMPOSER_CACHE_DIR}"
    sudo chmod -R 777 "${COMPOSER_CACHE_DIR}"
  fi

  if [[ ${MYSQL_ENABLE} == yes && ! -d "${project_dir}/sysdumps/mysql" ]]; then
    mkdir -p "${project_dir}/sysdumps/mysql"
  fi

  if [[ ${ELASTICSEARCH_ENABLE} == yes && ! -d "${project_dir}/sysdumps/elasticsearch/data" ]]; then
    mkdir -p "${project_dir}/sysdumps/elasticsearch/data"
  fi

  # backward compatibility ont-time moves, will be removed later
  # "db/", "es/", "node_modules/" directories were moved into "sysdumps/" dir in within project dir
  if [[ -d "${project_dir}/db/" && (! -d "${project_dir}/sysdumps/mysql/" || ! $(ls -a "${project_dir}/sysdumps/mysql/")) ]]; then
    #remove target directory to move without duplicated subdirectories
    sudo rm -f "${project_dir}/sysdumps/mysql/"
    sudo mv "${project_dir}/db" "${project_dir}/sysdumps/mysql"
    sudo chmod -R 777 "${project_dir}/sysdumps/mysql"
  fi

  if [[ -d "${project_dir}/sysdumps/db/" && (! -d "${project_dir}/sysdumps/mysql/" || ! $(ls -a "${project_dir}/sysdumps/mysql/")) ]]; then
    #remove target directory to move without duplicated subdirectories
    sudo rm -f "${project_dir}/sysdumps/mysql/"
    sudo mv "${project_dir}/sysdumps/db" "${project_dir}/sysdumps/mysql"
    sudo chmod -R 777 "${project_dir}/sysdumps/mysql"
  fi

  if [[ -d "${project_dir}/es/" && (! -d "${project_dir}/sysdumps/elasticsearch/" || ! $(ls -a "${project_dir}/sysdumps/elasticsearch/")) ]]; then
    #remove target directory to move without duplicated subdirectories
    sudo rm -f "${project_dir}/sysdumps/elasticsearch/"
    sudo mv "${project_dir}/es" "${project_dir}/sysdumps/elasticsearch"
    sudo chmod -R 777 "${project_dir}/sysdumps/elasticsearch"
  fi

  if [[ -d "${project_dir}/sysdumps/es/" && (! -d "${project_dir}/sysdumps/elasticsearch/" || ! $(ls -a "${project_dir}/sysdumps/elasticsearch/")) ]]; then
    #remove target directory to move without duplicated subdirectories
    sudo rm -f "${project_dir}/sysdumps/elasticsearch/"
    sudo mv "${project_dir}/sysdumps/es" "${project_dir}/sysdumps/elasticsearch"
    sudo chmod -R 777 "${project_dir}/sysdumps/elasticsearch"
  fi

  if [[ -d "${project_dir}/node_modules/" && (! -d "${project_dir}/sysdumps/node_modules/" || ! $(ls -a "${project_dir}/sysdumps/node_modules/")) ]]; then
    #remove target directory to move without duplicated subdirectories
    sudo rm -f "${project_dir}/sysdumps/node_modules/"
    sudo mv "${project_dir}/node_modules" "${project_dir}/sysdumps/node_modules"
    sudo chmod -R 777 "${project_dir}/sysdumps/node_modules"
  fi
}

############################ Local functions end ############################
