#!/usr/bin/env bash

require_once ${devbox_root}/tools/system/constants.sh
require_once ${devbox_root}/tools/system/output.sh

############################ Public functions ############################

get_project_list() {
  local _delimiter=${1-" "}
  local _project_list

  if [[ "${os_type}" = "macos" ]]; then
    # MacOs specific, use "gfind" for "-printf" option
    _project_list="$(gfind ${devbox_projects_dir}/ -maxdepth 1 -mindepth 1 -type d ! -path "*/archived_projects" -printf '%f\n' | sort -n | sed 's/ /£/' | tr '\n' "${_delimiter}")"
  elif [[ "${os_type}" = "linux" ]]; then
    _project_list="$(find ${devbox_projects_dir}/ -maxdepth 1 -mindepth 1 -type d ! -path "*/archived_projects" -printf '%f\n' | sort -n | sed 's/ /£/' | tr '\n' "${_delimiter}")"
  fi

  echo "${_project_list}"
}

############################ Public functions end ############################
