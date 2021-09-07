#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/docker/docker.sh"

############################ Public functions ############################

function docker_sync_start() {
  local _config_file=$1
  local _sync_name=${2-""}
  local _show_logs=${3-"1"}
  local _with_health_check=${4-"1"}

  if [[ -z "${_config_file}" || ! -f "${_config_file}" ]]; then
    show_error_message "Unable to start syncing. Docker-sync yml file not found at path  '${_config_file}'."
    exit 1
  fi

  if [[ -z "${_sync_name}" ]]; then
    _sync_names=$(get_config_file_sync_names "${_config_file}")
  else
    _sync_names="${_sync_name}"
  fi

  local _working_dir
  _working_dir=$(get_config_file_working_dir "${_config_file}")
  local _show_logs_for_syncs
  _show_logs_for_syncs="$(get_config_file_option ${_config_file} 'devbox_show_logs_for_syncs')"

  local _sync_strategy
  _sync_strategy="$(get_config_file_sync_strategy ${_config_file})"

  # start syncs using explicit docker-sync sync name to have separate daemon pid file and logging for each sync
  for _sync_name in ${_sync_names}; do
    if [[ "${_sync_strategy}" != "native" ]]; then
      if [[ "$(is_docker_container_exist '${_sync_name}')" == "0" ]]; then
        show_success_message "Starting initial synchronization for sync name '${_sync_name}'. Please wait" "3"
      else
        show_success_message "Starting background synchronization for sync name '${_sync_name}'" "3"
      fi
    fi

    if [[ ! -f "${_working_dir}/${_sync_name}.log" ]]; then
      touch "${_working_dir}/${_sync_name}.log"
    fi

    echo "[$(date)] Starting synchronization..." >>"${_working_dir}/${_sync_name}.log"

    if [[ "${_show_logs}" == "1" && -n "$(echo ${_show_logs_for_syncs} | grep ${_sync_name})" && "${_sync_strategy}" != "native" ]]; then
      if [[ -n "$(echo ${_show_logs_for_syncs} | grep ${_sync_name})" ]]; then
        show_success_message "Opening logs window for sync ${_sync_name}" "3"
        show_sync_logs_window "${_config_file}" "${_sync_name}"
      fi
    fi

    local _compose_project_name
    _compose_project_name="$(get_config_file_option ${_config_file} 'assign_sync_to_compose_project')"

    DOCKER_SYNC_SKIP_UPDATE=1 COMPOSE_PROJECT_NAME="${_compose_project_name}" docker-sync start --config="${_config_file}" --sync-name="${_sync_name}" --dir="${_working_dir}" --app_name="${_sync_name}" >>"${_working_dir}/${_sync_name}.log"

    if [[ "$?" != "0" ]]; then
      show_error_message "Unable to start sync volumes. See docker-sync output above. Process interrupted."
      show_error_message "Sync config file: ${_config_file}."
      exit 1
    fi

  done

  if [[ "${_with_health_check}" == "1" && "${_sync_strategy}" != "native" ]]; then
    start_background_health_checker "${_config_file}"
  fi
}

# stop syncing and watching the changes, stop command terminate all config syncs so sync_name is omited
function docker_sync_stop() {
  local _config_file=${1-""}
  local _kill_service_processes=${2-"1"}

  if [[ -z "${_config_file}" || ! -f "${_config_file}" ]]; then
    show_error_message "Unable to stop syncing. Docker-sync yml file not found at path  '${_config_file}'."
    exit 1
  fi

  local _sync_strategy
  _sync_strategy="$(get_config_file_sync_strategy ${_config_file})"

  if [[ "${_sync_strategy}" != "native" ]]; then
    show_success_message "Stopping docker-sync for all syncs from config '$(basename ${_config_file})'" "3"
  fi

  # terminate health-checker background processes
  if [[ "${_kill_service_processes}" == "1" && "${_sync_strategy}" != "native" ]]; then
    stop_background_health_checker "${_config_file}"
  fi

  local _working_dir
  _working_dir=$(get_config_file_working_dir "${_config_file}")

  docker-sync stop --config="${_config_file}" >>/dev/null

  if [[ "$?" != "0" ]]; then
    show_error_message "Unable to sync volumes. See docker-sync output above. Process interrupted."
    show_error_message "Sync config file: ${_config_file}."
    exit 1
  fi

  if [[ "${_kill_service_processes}" == "1" && "${_sync_strategy}" != "native"  ]]; then
    close_sync_logs_window "${_config_file}"
  fi
}

# cleanup volumes data, volumes will be emptied, should be called after stopping in case problems occurred or for final shutdowning of project
function docker_sync_clean() {
  local _config_file=$1
  local _sync_name=${2-""}

  if [[ -z "${_config_file}" || ! -f "${_config_file}" ]]; then
    show_error_message "Unable to clean syncs. Docker-sync yml file not found at path  '${_config_file}'."
    exit 1
  fi

  if [[ -z "${_sync_name}" ]]; then
    _sync_names=$(get_config_file_sync_names "${_config_file}")
  else
    _sync_names="${_sync_name}"
  fi

  local _working_dir
  _working_dir=$(get_config_file_working_dir "${_config_file}")

  local _sync_strategy
  _sync_strategy="$(get_config_file_sync_strategy ${_config_file})"

  for _sync_name in ${_sync_names}; do
    if [[ "${_sync_strategy}" != "native" ]]; then
      show_success_message "Cleaning docker-sync for sync name '${_sync_name}'" "3"
    fi

    docker-sync clean --config="${_config_file}" --sync-name="${_sync_name}" >>"${_working_dir}/${_sync_name}.log"

    if [[ "$?" != "0" ]]; then
      show_error_message "Unable to clean volumes syncs. See docker-sync output above. Process interrupted."
      show_error_message "Sync config file: ${_config_file}."
      exit 1
    fi
  done
}

# start syncronization for volumes in all "docker-sync-*.yml" in directory
function docker_sync_start_all_directory_volumes() {
  local _configs_directory=${1-''}
  local _show_logs=${2-"1"}
  local _with_health_check=${3-"1"}

  if [[ -z "${_configs_directory}" || ! -d "${_configs_directory}" ]]; then
    show_error_message "Unable to start syncs of docker volumes in directory '${_configs_directory}'. Working directory not found."
    exit 1
  fi

  for _project_sync_file in $(ls "${_configs_directory}" | grep "docker-sync-.*.yml" | awk '{ print $1 }'); do
    docker_sync_start "${_configs_directory}/${_project_sync_file}" "" "${_show_logs}" "${_with_health_check}"
  done
}

# start syncronization for volumes in all "docker-sync-*.yml" in directory
function docker_sync_stop_all_directory_volumes() {
  local _configs_directory=${1-''}
  local _kill_service_processes=${2-'1'}

  if [[ -z "${_configs_directory}" || ! -d "${_configs_directory}" ]]; then
    show_error_message "Unable to stop syncs of docker volumes in directory '${_configs_directory}'. Working directory not found."
    exit 1
  fi

  for _project_sync_file in $(ls "${_configs_directory}" | grep "docker-sync-.*.yml" | awk '{ print $1 }'); do
    docker_sync_stop "${_configs_directory}/${_project_sync_file}" "${_kill_service_processes}"
  done

  _project_dir=$(dirname "${_configs_directory}")
  kill_unison_orphan_processes "${_project_dir}"
}

# cleanup after syncronization for volumes in all "docker-sync-*.yml" in directory
function docker_sync_clean_all_directory_volumes() {
  local _configs_directory=$1

  if [[ -z "${_configs_directory}" || ! -d "${_configs_directory}" ]]; then
    show_error_message "Unable to clean syncs of docker volumes in directory '${_configs_directory}'. Working directory not found."
    exit 1
  fi

  for _project_sync_file in $(ls "${_configs_directory}" | grep "docker-sync-.*.yml" | awk '{ print $1 }'); do
    docker_sync_clean "${_configs_directory}/${_project_sync_file}"
  done
}

# get all syns names (equals to volume names) from the given config file
function get_config_file_sync_names() {
  local _config_file=$1
  local _sync_names=""

  if [[ ! -f "${_config_file}" ]]; then
    show_error_message "Unable to retrieve syncs name. File does not exist at path  '${_config_file}'."
    exit 1
  fi

  _sync_names=$(cat ${_config_file} | grep -A 100 "^syncs:" | grep -E "^\s{2,4}\S+" | tr -d ' :')

  echo "${_sync_names}"
}

# get working dir for syncs logs and pid-files
function get_config_file_working_dir() {
  local _config_file=$1
  local _working_dir=""

  if [[ ! -f "${_config_file}" ]]; then
    show_error_message "Unable to retrieve docker-sync config working dir."
    exit 1
  fi

  _working_dir="$(dirname ${_config_file})/docker-sync"
  if [[ ! -d "${_working_dir}" ]]; then
    mkdir -p "${_working_dir}"
  fi

  echo "${_working_dir}"
}

# get all syns names (equals to volume names) from the given config file
function get_directory_sync_names() {
  local _configs_directory=${1-""}

  if [[ ! -d "${_configs_directory}" ]]; then
    show_error_message "Unable to collect directory syncs names. Dir does not exist at path  '${_configs_directory}'."
    exit 1
  fi

  local _collected_sync_names=()

  for _project_sync_file in $(ls "${_configs_directory}" | grep "docker-sync-.*.yml" | awk '{ print $1 }'); do
    _config_sync_names=$(get_config_file_sync_names "${_configs_directory}/${_project_sync_file}")
    for _project_sync_file in $(echo "${_config_sync_names}" | tr ',' ' '); do
      _collected_sync_names[${#_collected_sync_names[@]}]="${_project_sync_file}"
    done
  done

  echo $(
    IFS=,
    echo "${_collected_sync_names[*]}"
  )
}

# get all syns names (equals to volume names) from the given config file
function get_config_file_by_directory_and_sync_name() {
  local _configs_directory=${1-""}
  local _sync_name=${2-""}

  if [[ ! -d "${_configs_directory}" ]]; then
    show_error_message "Unable to find config by sync name. Dir does not exist at path  '${_configs_directory}'."
    exit 1
  fi

  if [[ -z "${_sync_name}" ]]; then
    show_error_message "Unable to find config by sync name. Sync name cannot be empty. Given config dir: '${_configs_directory}'."
    exit 1
  fi

  for _project_sync_file in $(ls "${_configs_directory}" | grep "docker-sync-.*.yml" | awk '{ print $1 }'); do
    _config_sync_names=$(get_config_file_sync_names "${_configs_directory}/${_project_sync_file}")

    for _index in "${!_config_sync_names[@]}"; do
      if [[ "${_config_sync_names[${_index}]}" == "${_sync_name}" ]]; then
        echo "${_configs_directory}/${_project_sync_file}"
        return
      fi
    done
  done

  show_error_message "Unable to find config by sync name. Sync name '${_sync_name}' not found in directory '${_configs_directory}'."
}

############################ Public functions end ############################

############################ Local functions ############################

# open window with sync logs with runtime updating
function show_sync_logs_window() {
  local _config_file=${1-""}
  local _sync_name=${2-""}

  if [[ -z "${_config_file}" || ! -f "${_config_file}" ]]; then
    show_error_message "Unable to slow logs window. Required parameters are missing: config file - '${_config_file}'"
    exit 1
  fi

  _working_dir=$(get_config_file_working_dir "${_config_file}")
  if [[ -z "${_sync_name}" ]]; then
    _sync_names=$(get_config_file_sync_names "${_config_file}")
  else
    _sync_names="${_sync_name}"
  fi

  for _sync_name in ${_sync_names}; do
    if [[ "${os_type}" == "macos" ]]; then
      if [[ ! -f "${_working_dir}/${_sync_name}.log" ]]; then
        touch "${_working_dir}/${_sync_name}.log"
      fi

      # MacOs specific command to show logs
      osascript -e "tell application \"Terminal\" to do script \"tail -n 0 -f $(dirname ${_config_file})/docker-sync/${_sync_name}.log\"" >/dev/null
    elif [[ "${os_type}" == "linux" ]]; then
      true # do nothing
    fi
  done
}

# close window with sync logs
function close_sync_logs_window() {
  local _config_file=${1-""}
  local _sync_name=${2-""}

  if [[ -z "${_config_file}" || ! -f "${_config_file}" ]]; then
    show_error_message "Unable to slow logs window. Required parameters are missing: config file - '${_config_file}'"
    exit 1
  fi

  if [[ -z "${_sync_name}" ]]; then
    _sync_names=$(get_config_file_sync_names "${_config_file}")
  else
    _sync_names="${_sync_name}"
  fi

  for _sync_name in ${_sync_names}; do
    if [[ "${os_type}" == "macos" ]]; then
      if [[ -n $(ps aux | grep "tail -n 0 -f .*${_sync_name}.log" | grep -v 'grep' | awk -F" " '{print $2}') ]]; then
        osascript -e "tell application \"Terminal\" to close (every window whose name contains \"tail\" and name contains \"${_sync_name}\")" &
        # native linux killing, in MacOs if just terminates 'tail' process but does not close terminal window
        #ps aux | grep "tail -f .*${_sync_name}.log" | grep -v 'grep' | awk -F" " '{print $2}' | xargs kill -15
      fi
    fi
  done
}

#start health-checker process which will restart sync in case daemon pid file dissappeared (sync daemon errored)
function start_background_health_checker() {
  local _config_file=${1-""}

  if [[ -z "${_config_file}" || ! -f "${_config_file}" ]]; then
    show_error_message "Unable to slow logs window. Required parameters are missing: config file - '${_config_file}'"
    exit 1
  fi

  if [[ "${os_type}" == "macos" ]]; then
    # WinOs / MacOs specific, run Health-Checker in background
    nohup bash "${devbox_root}/tools/docker/docker-sync-health-checker.sh" "${_config_file}" >/dev/null &
  fi
}

# kill health-checker process
function stop_background_health_checker() {
  local _config_file=${1-""}

  if [[ -z "${_config_file}" || ! -f "${_config_file}" ]]; then
    show_error_message "Unable to slow logs window. Required parameters are missing: config file - '${_config_file}'"
    exit 1
  fi

  if [[ -n $(ps aux | grep "docker-sync-health-checker.sh" | grep "${_config_file}" | grep -v 'grep' | awk -F" " '{print $2}') ]]; then
    ps aux | grep "docker-sync-health-checker.sh" | grep "${_config_file}" | grep -v 'grep' | awk -F" " '{print $2}' | xargs kill -15
  fi
}

function kill_unison_orphan_processes() {
  local _project_dir=${1-""}

  if [[ -z "${_project_dir}" || ! -d "${_project_dir}" ]]; then
    show_error_message "Unable to kill unison orphan processes. Required project dir is missing at path - '${_project_dir}'"
    exit 1
  fi

  if [[ -n $(ps aux | grep "unison" | grep "${_project_dir}" | grep -v 'grep' | awk -F" " '{print $2}') ]]; then
    ps aux | grep "unison" | grep "${_project_dir}" | grep -v 'grep' | awk -F" " '{print $2}' | xargs kill -15
  fi
}

function get_config_file_option() {
  local _config_file=$1
  local _option_name=${2-""}

  if [[ ! -f "${_config_file}" ]]; then
    show_error_message "Unable to retrieve sync option. File does not exist at path  '${_config_file}'."
    exit 1
  fi

  if [[ -z "${_option_name}" ]]; then
    show_error_message "Unable to retrieve sync option. Option name cannot be empty"
    exit 1
  fi

  local _option_value
  _option_value=$(cat ${_config_file} | sed -n '/^options:/,/^syncs:/p' | grep "${_option_name}" | awk -F': ' '{print $2}')

  echo "${_option_value}"
}

function get_config_file_sync_strategy() {
  local _config_file=$1

  if [[ ! -f "${_config_file}" ]]; then
    show_error_message "Unable to retrieve sync option. File does not exist at path  '${_config_file}'."
    exit 1
  fi

  local _sync_strategy
  _sync_strategy=$(cat ${_config_file} | grep -A 20 "^syncs:" | grep "sync_strategy:" | awk -F': ' '{print $2}' | sed 's/#\s.*//' | tr -d " '")

  echo "${_sync_strategy}"
}

############################ Local functions end ############################
