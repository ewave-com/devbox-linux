#!/usr/bin/env bash

require_once ${devbox_root}/tools/system/constants.sh
require_once ${devbox_root}/tools/system/output.sh

############################ Public functions ############################

docker_compose_up() {
  local _compose_file=$1
  local _env_file=${2-"${project_up_dir}/.env"}
  local _silent=${3-"0"}
  local _log_level=${4-"${docker_compose_log_level}"}

  if [[ ! -f "${_compose_file}" ]]; then
    show_error_message "Unable to start containers. Docker-compose yml file not found at path  \"${_compose_file}\", related .env file: \"${_env_file}\"."
    exit 1
  fi

  if [[ -n "${_env_file}" && ! -f "${_env_file}" ]]; then
    show_error_message "Unable to start containers. Related .env path provided but file does not exist at path \"${_env_file}\. Compose file: \"${_compose_file}\""
    exit 1
  fi

  local _output_redirect=""
  if [[ ${_silent} == "1" ]]; then
    _output_redirect="> /dev/null"
  fi

  local _env_file_option=""
  if [[ -n "${_env_file}" ]]; then
    _env_file_option="--env-file ${_env_file}"
  fi

  sudo docker-compose \
    --file "${_compose_file}" \
    ${_env_file_option} \
    --log-level "${docker_compose_log_level}" \
    up -d \
    ${_output_redirect}

  if [[ "$?" != "0" ]]; then
    show_error_message "Unable to start containers. See docker-compose output above. Process interrupted."
    show_error_message "Compose file: ${_compose_file}, related .env file: ${_env_file}."
    exit 1
  fi
}

docker_compose_down() {
  local _compose_file=$1
  local _env_file=${2-"${project_up_dir}/.env"}
  local _silent=${3-"0"}
  local _log_level=${4-"${docker_compose_log_level}"}

  if [[ ! -f "${_compose_file}" ]]; then
    show_error_message "Unable to stop containers. Docker-compose yml file not found at path  \"${_compose_file}\"."
    exit 1
  fi

  local _env_file_option=""
  if [[ -n "${_env_file}" ]]; then
    _env_file_option="--env-file ${_env_file}"
  fi

  local _output_redirect=""
  if [[ ${_silent} == "1" ]]; then
    _output_redirect=" >/dev/null"
  fi

  sudo docker-compose \
    --file "${_compose_file}" \
    ${_env_file_option} \
    --log-level "${docker_compose_log_level}" \
    down \
    ${_output_redirect}

  if [[ "$?" != "0" ]]; then
    show_error_message "Unable to stop containers. See docker-compose output above. Process interrupted."
    show_error_message "Compose file: ${_compose_file}"
    exit 1
  fi
}

docker_compose_up_all_directory_services() {
  local _working_directory=$1
  local _env_file=${2-"${_working_directory}/.env"}
  local _silent=${3-"0"}
  local _log_level=${4-"${docker_compose_log_level}"}

  if [[ -z "${_working_directory}" || ! -d "${_working_directory}" ]]; then
    show_error_message "Unable to up docker services in directory \"${_working_directory}\". Working directory not found."
    exit 1
  fi

  for project_compose_file in $(ls "${_working_directory}" | grep "docker-compose-.*.yml" | awk '{ print $1 }'); do
    docker_compose_up "${_working_directory}/${project_compose_file}" "${_env_file}" "${_silent}" "${docker_compose_log_level}"
  done
}

docker_compose_down_all_directory_services() {
  local _working_directory=$1
  local _env_file=${2-"${_working_directory}/.env"}
  local _silent=${3-"0"}
  local _log_level=${4-"${docker_compose_log_level}"}

  if [[ -z "${_working_directory}" || ! -d "${_working_directory}" ]]; then
    show_error_message "Unable to down docker services in directory \"${_working_directory}\". Working directory not found."
    exit 1
  fi

  for project_compose_file in $(ls "${_working_directory}" | grep "docker-compose-.*.yml" | awk '{ print $1 }'); do
    docker_compose_down "${_working_directory}/${project_compose_file}" "${_env_file}" "${_silent}" "${docker_compose_log_level}"
  done
}

############################ Public functions end ############################
