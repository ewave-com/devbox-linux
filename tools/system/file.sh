#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

function copy_path() {
  local _from_path=$1
  local _to_path=$2
  #  local _silent_mode=${3:-"0"}

  if [[ -z ${_from_path} ]]; then
    show_error_message "Unable to copy source file '${_from_path}'. Path can not be empty. Debug info: Target path '${_to_path}'"
    exit 1
  fi

  if [[ ! -f ${_from_path} && ! -d ${_from_path} ]]; then
    show_error_message "Unable to copy file '${_from_path}'. Source path does not exist!"
    exit 1
  fi

  if [[ (-d ${_from_path} && -f ${_to_path}) ]]; then
    show_error_message "Unable to copy directory into file. Debug info: source path - '${_from_path}', target path - '${_to_path}'"
    exit 1
  fi

  if [[ (-f ${_from_path} && -d ${_to_path}) ]]; then
    _to_path="${_to_path}/"
  fi

  mkdir -p $(dirname "${_to_path}")

  if [[ (-d ${_from_path} && -d ${_to_path}) ]]; then
    cp -rf "${_from_path}"/* "${_to_path}"
  else
    cp -rf "${_from_path}" "${_to_path}"
  fi
}

function copy_path_with_project_fallback() {
  local _source_path=$1
  local _target_path=$2
  local _strict_mode=${3-"1"}

  local _is_copied="0"

  if [[ -f "${devbox_root}/${_source_path}" || -d "${devbox_root}/${_source_path}" ]]; then
    copy_path "${devbox_root}/${_source_path}" "${_target_path}"
    _is_copied="1"
  fi

  if [[ -f "${project_dir}/${_source_path}" || -d "${project_dir}/${_source_path}" ]]; then
    copy_path "${project_dir}/${_source_path}" "${_target_path}"
    _is_copied="1"
  fi

  if [[ "${_is_copied}" == 0 &&  "${_strict_mode}" == "1" ]]; then
    show_error_message "Unable to copy file: source path '${devbox_root}/${_source_path}' does not exist! Alternative fallback path also not found: '${project_dir}/${_source_path}'"
    exit 1
  else
    return 0
  fi
}

# Replace '\r\n\' endings with '\n'
function replace_file_line_endings() {
  local _filepath=${1-""}
  if [[ ! -f ${_filepath} ]]; then
    show_error_message "Unable to replace line endings. Target file doesn't exist at path '${_filepath}'."
    exit 1
  fi

  tr '\r\n' '\n' <"${_filepath}" >"${_filepath}.tmp"
  mv "${_filepath}.tmp" "${_filepath}"
}
############################ Public functions end ############################
