#!/usr/bin/env bash

require_once ${devbox_root}/tools/system/constants.sh
require_once ${devbox_root}/tools/system/output.sh

############################ Public functions ############################

docker_sync_start() {
  local _config_file=$1
  local _silent=${2-"0"}
  local _with_health_check=${3-"1"}

  if [[ ! -f "${_config_file}" ]]; then
    show_error_message "Unable to start syncing. Docker-sync yml file not found at path  \"${_config_file}\"."
    exit 1
  fi

  # start and stop syncs using explicit sync name as docker-sync will process only the first docker-sync.yml in demonized mode as it check single daemon PID
  # see https://github.com/EugenMayer/docker-sync/blob/master/tasks/sync/sync.thor#L168 (near "should_exit" variable inside "def daemonize")
  local _working_dir
  _working_dir=$(get_config_file_working_dir "${_config_file}")
  for _sync_name in $(get_config_file_sync_names "${_config_file}"); do
    docker-sync start -c "${_config_file}" -n "${_sync_name}" --dir="${_working_dir}" --app_name="${_sync_name}"
    if [[ "$?" != "0" ]]; then
      show_error_message "Unable to sync volumes. See docker-sync output above. Process interrupted."
      show_error_message "Sync config file: ${_config_file}."
      exit 1
    fi

    if [[ "${_silent}" = "0" ]]; then
      _show_logs_for_syncs="$(get_config_file_option ${_config_file} 'devbox_show_logs_for_syncs')"
      if [[ -n "$(echo ${_show_logs_for_syncs} | grep ${_sync_name})" ]]; then
        if [[ "${os_type}" = "macos" ]]; then
          # MacOs specific command to show logs
          osascript -e "tell application \"Terminal\" to do script \"tail -f $(dirname ${_config_file})/docker-sync/${_sync_name}.log\"" > /dev/null
        elif [[ "${os_type}" = "linux" ]]; then
          true # do nothing
        fi
      fi
    fi
  done

  if [[ "${os_type}" = "macos" ]]; then
    # WinOs / MacOs specific, run Health-Checker in background
    if [[ "${_with_health_check}" = "1" ]]; then
      nohup bash "${devbox_root}/tools/docker/docker-sync-health-checker.sh" "${devbox_root}" "${_config_file}" >/dev/null &
    fi
  elif [[ "${os_type}" = "linux" ]]; then
    true # do nothing
  fi
}

docker_sync_stop() {
  local _config_file=$1
  local _silent=${2-"0"}

  if [[ ! -f "${_config_file}" ]]; then
    show_error_message "Unable to stop syncing. Docker-sync yml file not found at path  \"${_config_file}\"."
    exit 1
  fi

  local _output_redirect=""
  if [[ ${_silent} == "1" ]]; then
    _output_redirect="> /dev/null"
  fi

  # terminate health-checker background processes
  if [[ -n $(ps aux | grep "docker-sync-health-checker.sh" | grep "${_config_file}" | grep -v 'grep' | awk -F" " '{print $2}') ]]; then
    ps aux | grep "docker-sync-health-checker.sh" | grep "${_config_file}" | grep -v 'grep' | awk -F" " '{print $2}' | xargs kill -15
  fi

  # start and stop syncs using explicit sync name as docker-sync will process only the first docker-sync.yml in demonized mode as it check single daemon PID
  # see https://github.com/EugenMayer/docker-sync/blob/master/tasks/sync/sync.thor#L168 (near "should_exit" variable inside "def daemonize")
  local _working_dir
  _working_dir=$(get_config_file_working_dir "${_config_file}")
  for _sync_name in $(get_config_file_sync_names "${_config_file}"); do
    docker-sync stop -c "${_config_file}" -n "${_sync_name}" --dir="${_working_dir}" --app_name="${_sync_name}" ${_output_redirect}
  done

  if [[ -n $(ps aux | grep "tail -f $(dirname ${_config_file})/docker-sync/${_sync_name}.log" | grep -v 'grep' | awk -F" " '{print $2}') ]]; then
    ps aux | grep "tail -f $(dirname ${_config_file})/docker-sync/${_sync_name}.log" | grep -v 'grep' | awk -F" " '{print $2}' | xargs kill -15
  fi

  if [[ "$?" != "0" ]]; then
    show_error_message "Unable to sync volumes. See docker-sync output above. Process interrupted."
    show_error_message "Sync config file: ${_config_file}."
    exit 1
  fi
}

docker_sync_start_all_directory_volumes() {
  local _working_directory=$1
  local _silent=${2-"0"}

  if [[ -z "${_working_directory}" || ! -d "${_working_directory}" ]]; then
    show_error_message "Unable to start sync docker volumes in directory \"${_working_directory}\". Working directory not found."
    exit 1
  fi

  for project_sync_file in $(ls "${_working_directory}" | grep "docker-sync-.*.yml" | awk '{ print $1 }'); do
    docker_sync_start "${_working_directory}/${project_sync_file}" "${_silent}"
  done
}

docker_sync_stop_all_directory_volumes() {
  local _working_directory=$1
  local _silent=${2-"0"}

  if [[ -z "${_working_directory}" || ! -d "${_working_directory}" ]]; then
    show_error_message "Unable to stop sync docker volumes in directory \"${_working_directory}\". Working directory not found."
    exit 1
  fi

  for project_sync_file in $(ls "${_working_directory}" | grep "docker-sync-.*.yml" | awk '{ print $1 }'); do
    docker_sync_stop "${_working_directory}/${project_sync_file}" "${_silent}"
  done
}

get_config_file_sync_names() {
  local _config_file=$1
  local _silent=${2-"0"}
  local _sync_names=""

  if [[ ! -f "${_config_file}" ]]; then
    show_error_message "Unable to retrieve syncs name. File does not exist at path  \"${_config_file}\"."
    exit 1
  fi

  _sync_names=$(cat ${_config_file} | grep -A 100 "^syncs:" | grep -E "^\s{2,4}\S" | tr -d ' :')

  echo "${_sync_names}"
}

get_config_file_working_dir() {
  local _config_file=$1
  local _dir=""

  if [[ ! -f "${_config_file}" ]]; then
    show_error_message "Unable to retrieve docker-sync config working dir."
    exit 1
  fi

  _dir="$(dirname ${_config_file})/docker-sync"

  echo "${_dir}"
}

############################ Public functions end ############################


############################ Local functions ############################

get_config_file_option() {
  local _config_file=$1
  local _option_name=${2-""}

  if [[ ! -f "${_config_file}" ]]; then
    show_error_message "Unable to retrieve sync option. File does not exist at path  \"${_config_file}\"."
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

############################ Local functions end ############################
