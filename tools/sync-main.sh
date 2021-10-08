#!/usr/bin/env bash

# import global variables
require_once "$devbox_root/tools/system/constants.sh"
# import output functions (print messages)
require_once "$devbox_root/tools/system/output.sh"
# import common functions for all projects structure
require_once "$devbox_root/tools/project/all-projects.sh"
# import common functions for all projects structure
require_once "$devbox_root/tools/docker/docker-sync.sh"
# import common functions for all projects structure
require_once "$devbox_root/tools/project/project-main.sh"

############################ Public functions ############################

function start_sync() {
  local _selected_project=${1-''}
  init_selected_project "${_selected_project}"

  if [[ "$(is_project_started ${_selected_project})" == "0" ]]; then
    show_warning_message "Project '${_selected_project}' is not started for this operation."
    exit 1
  fi

  docker_sync_start_all_directory_volumes "${project_up_dir}"
}

function stop_sync() {
  local _selected_project=${1-''}
  init_selected_project "${_selected_project}"

  if [[ "$(is_project_started ${_selected_project})" == "0" ]]; then
    show_warning_message "Project '${_selected_project}' is not started for this operation."
    exit 1
  fi

  docker_sync_stop_all_directory_volumes "${project_up_dir}"
}

function restart_sync() {
  local _selected_project=${1-''}
  init_selected_project "${_selected_project}"

  if [[ "$(is_project_started ${_selected_project})" == "0" ]]; then
    show_warning_message "Project '${_selected_project}' is not started for this operation."
    exit 1
  fi

  docker_sync_stop_all_directory_volumes "${project_up_dir}"

  docker_sync_start_all_directory_volumes "${project_up_dir}"
}

function open_log_window() {
  local _selected_project=${1-''}
  local _selected_sync_names=${2-''}

  init_selected_project $_selected_project

  if [[ "$(is_project_started ${_selected_project})" == "0" ]]; then
    show_warning_message "Project '${_selected_project}' is not started for this operation."
    exit 1
  fi

  if [[ "${_selected_sync_names}" == "all" ]]; then
    _selected_sync_names="$(get_directory_sync_names "${project_up_dir}")"
  fi

  for _sync_name in $(echo "${_selected_sync_names}" | tr ',' ' '); do
    _related_config_path="$(get_config_file_by_directory_and_sync_name "${project_up_dir}" "${_sync_name}")"

    show_sync_logs_window "${_related_config_path}" "${_sync_name}"
  done
}

############################ Public functions end ############################
