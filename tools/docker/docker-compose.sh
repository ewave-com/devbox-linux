#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

function docker_compose_up() {
  local _compose_filepath=$1
  local _env_filepath=${2-"${project_up_dir}/.env"}
  local _log_level=${3-"${docker_compose_log_level}"}

  show_success_message "Starting containers for docker-compose config '$(basename ${_compose_filepath})'" "3"

  if [[ ! -f "${_compose_filepath}" ]]; then
    show_error_message "Unable to start containers. Docker-compose yml file not found at path  '${_compose_filepath}', related .env file: '${_env_filepath}'."
    exit 1
  fi

  if [[ -n "${_env_filepath}" && ! -f "${_env_filepath}" ]]; then
    show_error_message "Unable to start containers. Related .env path provided but file does not exist at path '${_env_filepath}'. Compose file: '${_compose_filepath}'"
    exit 1
  fi

  local _env_file_option=""
  if [[ -n "${_env_filepath}" ]]; then
    _env_file_option="--env-file ${_env_filepath}"
  fi

  docker-compose \
    --file "${_compose_filepath}" \
    ${_env_file_option} \
    --log-level "${docker_compose_log_level}" \
    up --detach

  if [[ "$?" != "0" ]]; then
    show_error_message "Unable to start containers. See docker-compose output above. Process interrupted."
    show_error_message "Compose file: ${_compose_filepath}, related .env file: ${_env_filepath}."
    exit 1
  fi
}

function docker_compose_stop() {
  local _compose_filepath=$1
  local _env_filepath=${2-"${project_up_dir}/.env"}
  local _log_level=${3-"${docker_compose_log_level}"}

  show_success_message "Stopping containers for docker-compose config '$(basename ${_compose_filepath})'" "3"

  if [[ ! -f "${_compose_filepath}" ]]; then
    show_error_message "Unable to stop containers. Docker-compose yml file not found at path  '${_compose_filepath}', related .env file: '${_env_filepath}'."
    exit 1
  fi

  if [[ -n "${_env_filepath}" && ! -f "${_env_filepath}" ]]; then
    show_error_message "Unable to stop containers. Related .env path provided but file does not exist at path '${_env_filepath}'. Compose file: '${_compose_filepath}'"
    exit 1
  fi

  local _env_file_option=""
  if [[ -n "${_env_filepath}" ]]; then
    _env_file_option="--env-file ${_env_filepath}"
  fi

  docker-compose \
    --file "${_compose_filepath}" \
    ${_env_file_option} \
    --log-level "${docker_compose_log_level}" \
    stop

  if [[ "$?" != "0" ]]; then
    show_error_message "Unable to stop containers. See docker-compose output above. Process interrupted."
    show_error_message "Compose file: ${_compose_filepath}, related .env file: ${_env_filepath}."
    exit 1
  fi
}

function docker_compose_down() {
  local _compose_filepath=$1
  local _env_filepath=${2-"${project_up_dir}/.env"}
  local _clean_volumes=${3-"0"}
  local _log_level=${4-"${docker_compose_log_level}"}

  show_success_message "Downing docker containers for compose config '$(basename ${_compose_filepath})'" "3"

  if [[ ! -f "${_compose_filepath}" ]]; then
    show_error_message "Unable to down containers. Docker-compose yml file not found at path  '${_compose_filepath}'."
    exit 1
  fi

  if [[ -n "${_env_filepath}" && ! -f "${_env_filepath}" ]]; then
    show_error_message "Unable to down containers. Related .env path provided but file does not exist at path '${_env_filepath}'. Compose file: '${_compose_filepath}'"
    exit 1
  fi

  local _env_file_option=""
  if [[ -n "${_env_filepath}" ]]; then
    _env_file_option="--env-file ${_env_filepath}"
  fi

  if [[ "${_clean_volumes}" == "1" ]]; then
    COMPOSE_HTTP_TIMEOUT=10 docker-compose \
      --file "${_compose_filepath}" \
      ${_env_file_option} \
      --log-level "${docker_compose_log_level}" \
      down --volumes --timeout 10
  else
    COMPOSE_HTTP_TIMEOUT=10 docker-compose \
      --file "${_compose_filepath}" \
      ${_env_file_option} \
      --log-level "${docker_compose_log_level}" \
      down --timeout 10
  fi

  if [[ "$?" != "0" ]]; then
    show_error_message "Unable to down containers. See docker-compose output above. Process interrupted."
    show_error_message "Compose file: ${_compose_filepath}"
    exit 1
  fi
}

function docker_compose_down_and_clean() {
  local _compose_filepath=$1
  local _env_filepath=${2-"${project_up_dir}/.env"}
  local _log_level=${3-"${docker_compose_log_level}"}

  docker_compose_down "${_compose_filepath}" "${_env_filepath}" "1" "${_log_level}"
}

function docker_compose_up_all_directory_services() {
  local _working_directory=$1
  local _env_filepath=${2-"${_working_directory}/.env"}
  local _log_level=${3-"${docker_compose_log_level}"}

  if [[ -z "${_working_directory}" || ! -d "${_working_directory}" ]]; then
    show_error_message "Unable to up docker services in directory '${_working_directory}'. Working directory not found."
    exit 1
  fi

  if [[ -f "${_working_directory}/docker-compose-website.yml" ]]; then
    docker_compose_up "${_working_directory}/docker-compose-website.yml" "${_env_filepath}" "${docker_compose_log_level}"
  fi

  for _project_compose_filepath in $(ls "${_working_directory}" | grep "docker-compose-.*.yml" | grep -v "docker-compose-website.yml" | awk '{ print $1 }'); do
    docker_compose_up "${_working_directory}/${_project_compose_filepath}" "${_env_filepath}" "${docker_compose_log_level}"
  done
}

function docker_compose_stop_all_directory_services() {
  local _working_directory=$1
  local _env_filepath=${2-"${_working_directory}/.env"}
  local _log_level=${3-"${docker_compose_log_level}"}

  if [[ -z "${_working_directory}" || ! -d "${_working_directory}" ]]; then
    show_error_message "Unable to stop docker services in directory '${_working_directory}'. Working directory not found."
    exit 1
  fi

  for _project_compose_filepath in $(ls "${_working_directory}" | grep "docker-compose-.*.yml" | awk '{ print $1 }'); do
    docker_compose_stop "${_working_directory}/${_project_compose_filepath}" "${_env_filepath}" "${docker_compose_log_level}"
  done
}

function docker_compose_down_all_directory_services() {
  local _working_directory=$1
  local _env_filepath=${2-"${_working_directory}/.env"}
  local _log_level=${3-"${docker_compose_log_level}"}

  if [[ -z "${_working_directory}" || ! -d "${_working_directory}" ]]; then
    show_error_message "Unable to down docker services in directory '${_working_directory}'. Working directory not found."
    exit 1
  fi

  for _project_compose_filepath in $(ls "${_working_directory}" | grep "docker-compose-.*.yml" | awk '{ print $1 }'); do
    docker_compose_down "${_working_directory}/${_project_compose_filepath}" "${_env_filepath}" "0" "${docker_compose_log_level}"
  done
}

function docker_compose_down_and_clean_all_directory_services() {
  local _working_directory=$1
  local _env_filepath=${2-"${_working_directory}/.env"}
  local _log_level=${3-"${docker_compose_log_level}"}

  if [[ -z "${_working_directory}" || ! -d "${_working_directory}" ]]; then
    show_error_message "Unable to down docker services in directory '${_working_directory}'. Working directory not found."
    exit 1
  fi

  for _project_compose_filepath in $(ls "${_working_directory}" | grep "docker-compose-.*.yml" | awk '{ print $1 }'); do
    docker_compose_down_and_clean "${_working_directory}/${_project_compose_filepath}" "${_env_filepath}" "${docker_compose_log_level}"
  done
}

############################ Public functions end ############################
