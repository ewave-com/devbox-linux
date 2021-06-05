#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/system/file.sh"

export devbox_state_file_name="devbox.state"

############################ Public functions ############################

# check if param is presented in the devbox state file
function devbox_state_has_param() {
  local _param_name=${1-""}
  local _state_filepath="$(get_devbox_state_file_path)"

  devbox_state_init_file
  devbox_state_ensure_param_is_readable "${_param_name}"

  if [[ -n $(cat "${_state_filepath}" | grep "^${_param_name}=") ]]; then
    echo "1"
  else
    echo "0"
  fi
}

# get value the devbox state file by the param name
function devbox_state_get_param_value() {
  local _param_name=${1-""}
  local _state_filepath="$(get_devbox_state_file_path)"

  local _param_value=''

  if [[ "$(is_devbox_state_file_exists)" == "0" ]]; then
    echo "${_param_value}"
    return;
  fi

  devbox_state_ensure_param_is_readable "${_param_name}"

  if [[ -n $(cat "${_state_filepath}" | grep "^${_param_name}=") ]]; then
    _param_value=$(cat "${_state_filepath}" | grep "^${_param_name}=" | awk -F= '{print $2}')
  fi

  echo "${_param_value}"
}

# set value in the devbox state file by the param name
function devbox_state_set_param_value() {
  local _param_name=${1-""}
  local _param_value=${2-""}
  local _state_filepath="$(get_devbox_state_file_path)"

  devbox_state_init_file
  devbox_state_ensure_param_is_readable "${_param_name}"

  local _param_presented
  _param_presented=$(devbox_state_has_param "${_param_name}")
  if [[ "${_param_presented}" != "0" ]]; then
    sed_in_place "s|^${_param_name}=.*|${_param_name}=${_param_value}|g" "${_state_filepath}"
  else
    printf "%s=%s\n" "${_param_name}" "${_param_value}" >>"${_state_filepath}"
  fi
}

# get time of last update of docker images
function get_devbox_state_docker_images_updated_at() {
  local _status
  _status=$(devbox_state_get_param_value "docker_images_updated_at")

  echo "${_status}"
}

# set time of last update of docker images
function set_devbox_state_docker_images_updated_at() {
  local _value=${1-""}

  devbox_state_set_param_value "docker_images_updated_at" "${_value}"

  return
}

# get time in seconds since last update, current timestamp if last time is missing
function get_devbox_state_docker_images_updated_at_diff() {
  _current_timestamp=$(date +%s)
  _last_updated_timestamp=$(get_devbox_state_docker_images_updated_at)

  if [[ -z "${_last_updated_timestamp}" ]]; then
    echo "${_current_timestamp}"
    return
  fi

  echo $((${_current_timestamp} - ${_last_updated_timestamp}))
}

############################ Public functions end ############################

############################ Local functions ############################

# initialize state file if missing
function devbox_state_init_file() {
  local _state_filepath="$(get_devbox_state_file_path)"

  if [[ ! -f "${_state_filepath}" ]]; then
    touch "${_state_filepath}"
  fi
}

# check param name is presented and checked file exists
function devbox_state_ensure_param_is_readable() {
  local _param_name=${1-""}
  local _state_filepath="$(get_devbox_state_file_path)"

  if [[ -z "${_param_name}" ]]; then
    show_error_message "Unable to read DevBox state parameter. Param name cannot be empty"
    exit 1
  fi

  if [[ -z "${_state_filepath}" || ! -f "${_state_filepath}" ]]; then
    show_error_message "Unable to read DevBox state param. State file does not exist at path '${_state_filepath}'."
    exit 1
  fi
}

# return devbox state file path
function get_devbox_state_file_path() {
  local _state_filepath="${devbox_root}/${devbox_state_file_name}"

  echo "${_state_filepath}";
}

# check if DevBox state file exists
function is_devbox_state_file_exists() {
  local _state_filepath="$(get_devbox_state_file_path)"

  if [[ -f "${_state_filepath}" ]]; then
    echo "1";
  fi

  echo "0";
}

############################ Local functions end ############################
