#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/file.sh"
require_once "${devbox_root}/tools/system/output.sh"

export state_file_name="project.state"

############################ Public functions ############################

# check if project state file exists
function is_state_file_exists() {
  local _state_filepath=${1-"${project_up_dir}/${state_file_name}"}

  if [[ -d "${_state_filepath}" ]]; then
    _state_filepath="${_state_filepath}/${state_file_name}"
  fi

  if [[ -f "${_state_filepath}" ]]; then
    echo "1";
  fi

  echo "0";
}

# get hash of project dotenv file for comparison
function get_state_dotenv_hash() {
  local _state_filepath=${1-"${project_up_dir}/${state_file_name}"}

  local _stored_dotenv_hash
  _stored_dotenv_hash=$(state_get_param_value "dotenv_hash" "${_state_filepath}")

  echo "${_stored_dotenv_hash}"
}

# save hash of project dotenv file
function set_state_dotenv_hash() {
  local _value=${1-""}
  local _state_filepath=${2-"${project_up_dir}/${state_file_name}"}

  if [[ -z ${_value} ]]; then
    _value=$(get_file_md5_hash "${project_dir}/.env")
  fi

  state_set_param_value "dotenv_hash" "${_value}" "${_state_filepath}"

  return 0
}

# get last project status, available values: empty, "starting", "started", "stopping", "stopped"
function get_state_last_project_status() {
  local _state_filepath=${1-"${project_up_dir}/${state_file_name}"}

  local _status
  _status=$(state_get_param_value "project_status" "${_state_filepath}")

  echo "${_status}"
}

# save project status, available values: "starting", "started", "stopping", "stopped"
function set_state_last_project_status() {
  local _value=${1-""}
  local _state_filepath=${2-"${project_up_dir}/${state_file_name}"}

  state_set_param_value "project_status" "${_value}" "${_state_filepath}"

  return 0
}

function remove_state_file() {
  local _state_filepath=${1-"${project_up_dir}/${state_file_name}"}

  if [[ -d "${_state_filepath}" ]]; then
    _state_filepath="${_state_filepath}/${state_file_name}"
  fi

  if [[ -f "${_state_filepath}" ]]; then
    rm "${_state_filepath}"
  fi
}

############################ Public functions end ############################

############################ Local functions ############################

# check if param is presented in the given state file
function state_has_param() {
  local _param_name=${1-""}
  local _state_filepath=${2-"${project_up_dir}/${state_file_name}"}

  if [[ -d "${_state_filepath}" ]]; then
    _state_filepath="${_state_filepath}/${state_file_name}"
  fi

  init_state_file "${_state_filepath}"
  state_ensure_param_is_readable "${_param_name}" "${_state_filepath}"

  if [[ -n $(cat "${_state_filepath}" | grep "^${_param_name}=") ]]; then
    echo "1"
  else
    echo "0"
  fi
}

# get value the given state file by the param name
function state_get_param_value() {
  local _param_name=$1
  local _state_filepath=${2-"${project_up_dir}/${state_file_name}"}

  if [[ -d "${_state_filepath}" ]]; then
    _state_filepath="${_state_filepath}/${state_file_name}"
  fi

  local _param_value=''

  if [[ $(is_state_file_exists "${_state_filepath}") == "0" ]]; then
    echo "${_param_value}"
    return;
  fi

  state_ensure_param_is_readable "${_param_name}" "${_state_filepath}"

  if [[ -n $(cat "${_state_filepath}" | grep "^${_param_name}=") ]]; then
    _param_value=$(cat "${_state_filepath}" | grep "^${_param_name}=" | awk -F= '{print $2}')
  fi

  echo "${_param_value}"
}

# set value in the given state file by the param name
function state_set_param_value() {
  local _param_name=${1-""}
  local _param_value=${2-""}
  local _state_filepath=${3-"${project_up_dir}/${state_file_name}"}

  if [[ -d "${_state_filepath}" ]]; then
    _state_filepath="${_state_filepath}/${state_file_name}"
  fi

  init_state_file "${_state_filepath}"
  state_ensure_param_is_readable "${_param_name}" "${_state_filepath}"

  local _param_presented
  _param_presented=$(state_has_param "${_param_name}" "${_state_filepath}")
  if [[ "${_param_presented}" != "0" ]]; then
    sed_in_place "s|^${_param_name}=.*|${_param_name}=${_param_value}|g" "${_state_filepath}"
  else
    printf "%s=%s\n" "${_param_name}" "${_param_value}" >>"${_state_filepath}"
  fi
}

# initialize state file if missing
function init_state_file() {
  local _state_filepath=${1-"${project_up_dir}/${state_file_name}"}

  if [[ -d "${_state_filepath}" ]]; then
    _state_filepath="${_state_filepath}/${state_file_name}"
  fi

  if [[ ! -d "$(dirname "${_state_filepath}")" ]]; then
    mkdir -p "$(dirname "${_state_filepath}")"
  fi

  if [[ ! -f "${_state_filepath}" ]]; then
    touch "${_state_filepath}"
  fi
}

# check param name is presented and checked file exists
function state_ensure_param_is_readable() {
  local _param_name=$1
  local _state_filepath=${2-"${project_up_dir}/${state_file_name}"}

  if [[ -d "${_state_filepath}" ]]; then
    _state_filepath="${_state_filepath}/${state_file_name}"
  fi

  if [[ -z "${_param_name}" ]]; then
    show_error_message "Unable to read project state parameter. Param name cannot be empty"
    exit 1
  fi

  if [[ -z "${_state_filepath}" || ! -f "${_state_filepath}" ]]; then
    show_error_message "Unable to read project state param. State file does not exist at path '${_state_filepath}'."
    exit 1
  fi
}

############################ Local functions end ############################
