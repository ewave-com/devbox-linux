#!/usr/bin/env bash
# info: actions with env file

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/free-port.sh"
require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

# Function which exports variable from ENV file
function dotenv_export_variables() {
  local _env_filepath=${1-""}

  if [[ -z "${_env_filepath}" || ! -f "${_env_filepath}" ]]; then
    show_error_message "Unable to export .env params. File doesn't exist at path '${_env_filepath}'."
    exit 1
  fi

  export $(cat "${_env_filepath}" | grep -Ev "^$" | grep -v '^#' | xargs)
}

# Function which unset variable from ENV file
function dotenv_unset_variables() {
  local _env_filepath=${1-""}

  if [[ -z "${_env_filepath}" || ! -f "${_env_filepath}" ]]; then
    show_error_message "Unable to unset .env params. File doesn't exist at path '${_env_filepath}'."
    exit 1
  fi

  unset $(cat "${_env_filepath}" | grep -Ev "^$" | grep -v '^#' | sed -E 's/(.*)=.*/\1/' | xargs)
}

# check if param is presented in the given .env file
function dotenv_has_param() {
  local _param_name=$1
  local _env_filepath=${2-"${current_env_filepath}"}

  dotenv_ensure_param_is_readable "${_param_name}" "${_env_filepath}"

  local _param_presented
  _param_presented=$(cat "${_env_filepath}" | grep "^${_param_name}=")
  if [[ -n ${_param_presented} ]]; then
    echo "1"
  else
    echo "0"
  fi
}

# check if param has not empty value in the given .env file
function dotenv_has_param_value() {
  local _param_name=$1
  local _env_filepath=${2-"${current_env_filepath}"}

  dotenv_ensure_param_is_readable "${_param_name}" "${_env_filepath}"

  local _param_value
  _param_value=$(dotenv_get_param_value "${_param_name}" "${_env_filepath}")
  if [[ -n ${_param_value} ]]; then
    echo "1"
  else
    echo "0"
  fi
}

# get value the given .env file by the param name
function dotenv_get_param_value() {
  local _param_name=$1
  local _env_filepath=${2-"${current_env_filepath}"}

  dotenv_ensure_param_is_readable "${_param_name}" "${_env_filepath}"

  local _param_value=''
  if [[ -n $(cat "${_env_filepath}" | grep "^${_param_name}=") ]]; then
    _param_value=$(cat "${_env_filepath}" | grep "^${_param_name}=" | awk -F= '{print $2}')
  fi

  echo "${_param_value}"
}

# set value the given .env file by the param name
function dotenv_set_param_value() {
  local _param_name=$1
  local _param_value=${2-""}
  local _env_filepath=${3-"${current_env_filepath}"}

  dotenv_ensure_param_is_readable "${_param_name}" "${_env_filepath}"

  local _param_presented
  _param_presented=$(dotenv_has_param "${_param_name}" "${_env_filepath}")
  if [[ "${_param_presented}" != "0" ]]; then
    if [[ "${os_type}" == "macos" ]]; then
      sed -i '' "s|^${_param_name}=.*|${_param_name}=${_param_value}|g" ${_env_filepath}
    elif [[ "${os_type}" == "linux" ]]; then
      sed -i "s|^${_param_name}=.*|${_param_name}=${_param_value}|g" ${_env_filepath}
    fi
  else
    echo -en "${_param_name}=${_param_value}\n" >>"${_env_filepath}"
  fi
}

# replace file patterns '{{_PARAM_NAME_}}' with corresponding values from .env file
function replace_file_patterns_with_dotenv_params() {
  local _filepath=${1-""}
  local _env_filepath=${2-"${current_env_filepath}"}

  if [[ -z ${_filepath} ]]; then
    show_error_message "Unable to replace config value at path '${_filepath}'. Path can not be empty."
    exit 1
  fi

  if [[ ! -f ${_filepath} ]]; then
    show_error_message "Unable to replace patterns with env params at path '${_filepath}'. Path does not exist!"
    exit 1
  fi

  local _pattern
  local _param_value
  local _unprocessed_pattern_found="0"
  for _pattern in $(cat "${_filepath}" | grep -oE "\{\{[A-Za-z0-9_-]*\}\}"); do
    local _param_name
    _param_name=$(echo "${_pattern}" | sed -E 's/[{}]//g')

    # read variable from exported shell variables if exists
    if [[ ! -z "${_param_name+x}" ]]; then
      _param_value="$(printenv ${_param_name})"
      replace_value_in_file "${_filepath}" "${_pattern}" "${_param_value}"
      continue
    fi

    local _param_presented
    _param_presented=$(dotenv_has_param "${_param_name}" "${_env_filepath}")
    # search for pattern variable in project .env file if presented
    if [[ "${_param_presented}" == "1" ]]; then
      _param_value=$(dotenv_get_param_value "${_param_name}" "${_env_filepath}")
      replace_value_in_file "${_filepath}" "${_pattern}" "${_param_value}"
      continue
    fi

    _unprocessed_pattern_found="1"
    show_warning_message "Unprocessed pattern '${_pattern}' found at path '${_filepath}'"
  done

  if [[ "${_unprocessed_pattern_found}" != "0" ]]; then
    show_error_message "Not all patterns were prepared at path '${_filepath}'."
    show_error_message "Ensure all required params are presented in project .env file or contact DevBox developers."
    exit 1
  fi
}

# replace patterns '{{_PARAM_NAME_}}' in all directory files with corresponding values from .env file
function replace_directory_files_patterns_with_dotenv_params() {
  local _dir_path=${1-""}
  local _env_filepath=${2-"${current_env_filepath}"}

  if [[ -z "${_dir_path}" ]]; then
    show_error_message "Unable to replace directory files with dotenv variables. Directory path cannot be empty."
    exit 1
  fi

  if [[ ! -d "${_dir_path}" ]]; then
    show_error_message "Unable to replace directory files with dotenv variables. Directory does not exist at path '${_dir_path}'."
    exit 1
  fi

  if [[ "${_dir_path: -1}" == "/" ]]; then
    _dir_path="$(echo ${_dir_path} | sed 's|/$||')"
  fi

  for _config_path in $(find "${_dir_path}" -type f); do
    # remove extension ".pattern" from the file path if presented
    if [[ "${_config_path: -8}" == ".pattern" ]]; then
      _new_config_path="$(echo ${_config_path} | sed 's|.pattern$||')"
      mv "${_config_path}" "${_new_config_path}"
      _config_path="${_new_config_path}"
    fi

    replace_file_patterns_with_dotenv_params "${_config_path}" "${_env_filepath}"
  done
}

############################ Public functions end ############################

############################ Local functions ############################

# check param name is presented and checked file exists
function dotenv_ensure_param_is_readable() {
  local _param_name=$1
  local _env_filepath=${2-"${current_env_filepath}"}

  if [[ -z "${_param_name}" ]]; then
    show_error_message "Unable to read .env value. Param name cannot be empty"
    exit 1
  fi

  if [[ -z "${_env_filepath}" || ! -f "${_env_filepath}" ]]; then
    show_error_message "Unable to read .env param. Project .env file does not exist at path '${_env_filepath}'."
    exit 1
  fi
}

############################ Local functions end ############################
