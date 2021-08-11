#!/usr/bin/env bash

if [ -z "${imported_scripts+x}" ]; then
  declare -a imported_scripts=()
#  export imported_scripts
fi

############################ Public functions ############################

function require_once() {
  local _included_path=${1-''}
  local _RED='\033[0;31m'
  local _SET='\033[0m'

  if [[ -z ${_included_path} ]]; then
    echo -e "${_RED} Unable to include source. Included path cannot be empty ${_SET}"
    exit 1
  fi

  if [[ ! -f "${_included_path}" && (-z "${devbox_root+x}" && -f "${devbox_root}/${_included_path}") ]]; then
    _included_path="${devbox_root}/${_included_path}"
  fi

  if [[ ! -f ${_included_path} ]]; then
    echo -e "${_RED} Unable to include source. Included file does not exist at path ${_included_path} ${_SET}"
    exit 1
  fi

  for index in "${!imported_scripts[@]}"; do
    if [[ "${imported_scripts[${index}]}" == "${_included_path}" ]]; then
      return 0
    fi
  done

  # bash 4.0+ feature
  #  if [[ -v imported_scripts["${_included_path}"] ]]; then
  #    return 0
  #  fi

  # the following function and variable checks needed for cases script was imported before without require_once
  local _first_func
  _first_func=$(cat "${_included_path}" | grep -oE '^([A-Za-z0-9_\-]+)[ ]?\(\)[ ]?\{?[ ]*$' | head -n 1 | awk -F"[ (]" '{print $1}')
  if type "${_first_func}" 2>/dev/null | grep -q 'function'; then
    #    imported_scripts["${_included_path}"]="1"
    imported_scripts[${#imported_scripts[@]}]="${_included_path}"
    return 0
  fi

  imported_scripts[${#imported_scripts[@]}]="${_included_path}"
  #  imported_scripts["${_included_path}"]="1"

  source "${_included_path}"
}

############################ Public functions end ############################
