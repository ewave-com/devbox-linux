#!/usr/bin/env bash

#devbox_infra_dir=${devbox_root}/configs/infrastructure
reversproxy_dir=${devbox_infra_dir}/nginx-reversproxy

require_once ${devbox_root}/tools/docker/docker-compose.sh
require_once ${devbox_root}/tools/docker/docker.sh
require_once ${devbox_root}/tools/docker/network.sh
require_once ${devbox_root}/tools/system/output.sh

############################ Public functions ############################

# Function which start nginx,portainer,mailhog
start_infrastructure() {
  create_docker_network

  local _dotenv_filepath
  _dotenv_filepath=$(get_infra_dotenv_path)

  start_portainer "${_dotenv_filepath}"

  start_nginx_reverse_proxy "${_dotenv_filepath}"

  if [[ "${MAILER_TYPE}" == "mailhog" || "${MAILER_TYPE}" == "exim4" ]]; then
    start_mailer "${_dotenv_filepath}"
  fi

  if [[ "${ADMINER_ENABLE}" == "yes" ]]; then
    start_adminer "${_dotenv_filepath}"
  fi
}

down_infrastructure() {
  local _dotenv_filepath
  _dotenv_filepath=$(get_infra_dotenv_path)

  for infrastructure_compose_file in $(ls "${devbox_infra_dir}/" | grep .yml | awk '{ print $1 }'); do
    docker_compose_down "${devbox_infra_dir}/${infrastructure_compose_file}" "${_dotenv_filepath}"
  done

  rm -rf "${devbox_infra_dir}/nginx-reversproxy/run/conf.d/*"

  # sometimes infrastructure containers may hang after downing, kill and rm them to avoid this, also this helps to clear all orhaned data
  [[ "$(is_docker_container_running 'nginx-reverse-proxy')" == "1" ]] && kill_container_by_name "nginx-reverse-proxy" "0" "SIGTERM"
  [[ "$(is_docker_container_exist 'nginx-reverse-proxy')" == "1" ]] && set +e && rm_container_by_name "nginx-reverse-proxy" && set -e

  [[ "$(is_docker_container_running 'portainer')" == "1" ]] && kill_container_by_name "portainer"
  [[ "$(is_docker_container_exist 'portainer')" == "1" ]] && rm_container_by_name "portainer"

  [[ "$(is_docker_container_running 'mailer')" == "1" ]] && kill_container_by_name "mailer"
  [[ "$(is_docker_container_exist 'mailer')" == "1" ]] && rm_container_by_name "mailer"

  [[ "$(is_docker_container_running 'adminer')" == "1" ]] && kill_container_by_name "adminer"
  [[ "$(is_docker_container_exist 'adminer')" == "1" ]] && rm_container_by_name "adminer"

  remove_docker_network
}

############################ Public functions end ############################

############################ Local functions ############################

start_nginx_reverse_proxy() {
  local _dotenv_path=${1-"${dotenv_defaults_filepath}"}
  if [[ "$(is_docker_container_running 'nginx-reverse-proxy')" == "0" ]]; then
    docker_compose_up "${devbox_infra_dir}/docker-compose-nginx-reverse-proxy.yml" "${_dotenv_path}"
  fi
}

start_portainer() {
  local _dotenv_path=${1-"${dotenv_defaults_filepath}"}

  if [[ "$(is_docker_container_running 'portainer')" == "0" ]]; then
    docker_compose_up "${devbox_infra_dir}/docker-compose-portainer.yml" "${_dotenv_path}"
  fi
}

start_mailer() {
  local _dotenv_path=${1-"${dotenv_defaults_filepath}"}
  if [[ "$(is_docker_container_running 'mailer')" == "0" ]]; then
    if [[ "${MAILER_TYPE}" == "mailhog" ]]; then
      docker_compose_up "${devbox_infra_dir}/docker-compose-mailhog.yml" "${_dotenv_path}"
      return 0
    fi

    if [[ "${MAILER_TYPE}" == "exim4" ]]; then
      docker_compose_up "${devbox_infra_dir}/docker-compose-exim4.yml" "${_dotenv_path}"
      return 0
    fi
  fi
}

start_adminer() {
  local _dotenv_path=${1-"${dotenv_defaults_filepath}"}
  if [[ "$(is_docker_container_running 'adminer')" == "0" ]]; then
    docker_compose_up "${devbox_infra_dir}/docker-compose-adminer.yml" "${_dotenv_path}"
  fi
}

get_infra_dotenv_path() {
  local _dotenv_filepath
  if [[ "${project_up_dir+x}" == "x" && -f "${project_up_dir}/.env" ]]; then
    _dotenv_filepath="${project_up_dir}/.env"
  else
    _dotenv_filepath="${dotenv_defaults_filepath}"
  fi

  echo "${_dotenv_filepath}"
}
############################ Local functions end ############################
