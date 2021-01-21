#!/usr/bin/env bash

require_once "${devbox_root}/tools/docker/docker-compose.sh"
require_once "${devbox_root}/tools/docker/docker.sh"
require_once "${devbox_root}/tools/docker/network.sh"
require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/system/file.sh"
require_once "${devbox_root}/tools/system/dotenv.sh"

############################ Public functions ############################

# Start infrastructure docker services, e.g. nginx, portainer, mailhog, etc.
function start_infrastructure() {
  local _dotenv_filepath=${1-"${dotenv_infra_filepath}"}

  replace_file_line_endings "${_dotenv_filepath}"

  create_docker_network

  if [[ "$(is_docker_container_running 'portainer')" == "0" ]]; then
    ensure_port_is_available $(dotenv_get_param_value 'PORTAINER_PORT' "${_dotenv_filepath}")
    docker_compose_up "${devbox_infra_dir}/docker-compose-portainer.yml" "${_dotenv_filepath}"
  fi

  if [[ "$(is_docker_container_running 'nginx-reverse-proxy')" == "0" ]]; then
    ensure_port_is_available "80"
    ensure_port_is_available "443"

    docker_compose_up "${devbox_infra_dir}/docker-compose-nginx-reverse-proxy.yml" "${_dotenv_filepath}"
  fi

  _mailer_type=$(dotenv_get_param_value 'MAILER_TYPE' "${_dotenv_filepath}")
  if [[ "${_mailer_type}" == "mailhog" || "${_mailer_type}" == "exim4" ]]; then
    if [[ "$(is_docker_container_running 'mailer')" == "0" ]]; then
      if [[ "${_mailer_type}" == "mailhog" ]]; then
        ensure_port_is_available $(dotenv_get_param_value 'MAILHOG_PORT' "${_dotenv_filepath}")

        docker_compose_up "${devbox_infra_dir}/docker-compose-mailhog.yml" "${_dotenv_filepath}"
      elif [[ "${_mailer_type}" == "exim4" ]]; then
        docker_compose_up "${devbox_infra_dir}/docker-compose-exim4.yml" "${_dotenv_filepath}"
      fi
    fi
  fi

  if [[ $(dotenv_get_param_value 'ADMINER_ENABLE' "${_dotenv_filepath}") == "yes" ]]; then
    if [[ "$(is_docker_container_running 'adminer')" == "0" ]]; then
      ensure_port_is_available $(dotenv_get_param_value 'ADMINER_PORT' "${_dotenv_filepath}")
      docker_compose_up "${devbox_infra_dir}/docker-compose-adminer.yml" "${_dotenv_filepath}"
    fi
  fi
}

# Stop infrastructure docker services
function stop_infrastructure() {
  local _dotenv_filepath=${1-"${dotenv_infra_filepath}"}

  replace_file_line_endings "${_dotenv_filepath}"

  if [[ "$(is_docker_container_running 'mailer')" == "1" ]]; then
    _mailer_type=$(dotenv_get_param_value 'MAILER_TYPE' "${_dotenv_filepath}")
    if [[ "${_mailer_type}" == "mailhog" ]]; then
      docker_compose_down "${devbox_infra_dir}/docker-compose-mailhog.yml" "${_dotenv_filepath}"
    elif [[ "${_mailer_type}" == "exim4" ]]; then
      docker_compose_down "${devbox_infra_dir}/docker-compose-exim4.yml" "${_dotenv_filepath}"
    fi
  fi

  if [[ "$(is_docker_container_running 'adminer')" == "1" ]]; then
    docker_compose_down "${devbox_infra_dir}/docker-compose-adminer.yml" "${_dotenv_filepath}"
  fi

  rm -rf "${devbox_infra_dir}/nginx-reverse-proxy/run/conf.d/"*
  rm -rf "${devbox_infra_dir}/nginx-reverse-proxy/run/logs/"*
  rm -rf "${devbox_infra_dir}/nginx-reverse-proxy/run/ssl/"*
  if [[ "$(is_docker_container_running 'nginx-reverse-proxy')" == "1" ]]; then
    docker_compose_down "${devbox_infra_dir}/docker-compose-nginx-reverse-proxy.yml" "${_dotenv_filepath}"
  fi

  if [[ "$(is_docker_container_running 'portainer')" == "1" ]]; then
    docker_compose_down "${devbox_infra_dir}/docker-compose-portainer.yml" "${_dotenv_filepath}"
  fi
}

# Down infrastructure docker services
function down_infrastructure() {
  local _dotenv_filepath=${1-"${dotenv_infra_filepath}"}

  replace_file_line_endings "${_dotenv_filepath}"

  # sometimes infrastructure containers may hang after downing, kill and rm them to avoid this, also this helps to clear all orphaned data
  # nginx-reverse proxy has additional kill signal and called as background task because of this

  # down mailer
  if [[ "$(is_docker_container_running 'mailer')" == "1" ]]; then
    _mailer_type=$(dotenv_get_param_value 'MAILER_TYPE' "${_dotenv_filepath}")
    if [[ "${_mailer_type}" == "mailhog" ]]; then
      docker_compose_down "${devbox_infra_dir}/docker-compose-mailhog.yml" "${_dotenv_filepath}"
    elif [[ "${_mailer_type}" == "exim4" ]]; then
      docker_compose_down "${devbox_infra_dir}/docker-compose-exim4.yml" "${_dotenv_filepath}"
    fi
  fi
  [[ "$(is_docker_container_running 'mailer')" == "1" ]] && kill_container_by_name "mailer"
  [[ "$(is_docker_container_exist 'mailer')" == "1" ]] && rm_container_by_name "mailer"

  # down adminer
  if [[ "$(is_docker_container_running 'adminer')" == "1" ]]; then
    docker_compose_down "${devbox_infra_dir}/docker-compose-adminer.yml" "${_dotenv_filepath}"
  fi
  [[ "$(is_docker_container_running 'adminer')" == "1" ]] && kill_container_by_name "adminer"
  [[ "$(is_docker_container_exist 'adminer')" == "1" ]] && rm_container_by_name "adminer"

  # down nginx-reverse-proxy
  rm -rf "${devbox_infra_dir}/nginx-reverse-proxy/run/conf.d/"*
  rm -rf "${devbox_infra_dir}/nginx-reverse-proxy/run/logs/"*
  rm -rf "${devbox_infra_dir}/nginx-reverse-proxy/run/ssl/"*
  if [[ "$(is_docker_container_running 'nginx-reverse-proxy')" == "1" ]]; then
    docker_compose_down "${devbox_infra_dir}/docker-compose-nginx-reverse-proxy.yml" "${_dotenv_filepath}"
  fi
  [[ "$(is_docker_container_running 'nginx-reverse-proxy')" == "1" ]] && kill_container_by_name "nginx-reverse-proxy" "SIGTERM" &
  [[ "$(is_docker_container_exist 'nginx-reverse-proxy')" == "1" ]] && set +e && rm_container_by_name "nginx-reverse-proxy" && set -e

  # down portainer
  if [[ "$(is_docker_container_running 'portainer')" == "1" ]]; then
    docker_compose_down "${devbox_infra_dir}/docker-compose-portainer.yml" "${_dotenv_filepath}"
  fi
  [[ "$(is_docker_container_running 'portainer')" == "1" ]] && kill_container_by_name "portainer"
  [[ "$(is_docker_container_exist 'portainer')" == "1" ]] && rm_container_by_name "portainer"

  remove_docker_network
}

############################ Public functions end ############################
