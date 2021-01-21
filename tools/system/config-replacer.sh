#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

function replace_value_in_file() {
  local _filepath=$1
  local _needle=$2
  local _replacement=$3

  if [[ -z ${_filepath} ]]; then
    show_error_message "Unable to replace config value at path '${_filepath}'. Path can not be empty."
    exit 1
  fi

  if [[ ! -f ${_filepath} ]]; then
    show_error_message "Unable to replace config value at path '${_filepath}'. Path does not exist! Needle '${_needle}', replacement '${_replacement}'"
    exit 1
  fi

  if [[ -z ${_needle} ]]; then
    show_error_message "Unable to replace config value at path '${_filepath}'. Needle can not be empty!"
    exit 1
  fi

  if [[ "${os_type}" == "macos" ]]; then
    sed -i '' "s|${_needle}|${_replacement}|g" ${_filepath}
  elif [[ "${os_type}" == "linux" ]]; then
    sed -i "s|${_needle}|${_replacement}|g" ${_filepath}
  fi
}

############################ Public functions end ############################
