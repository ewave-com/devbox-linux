#!/usr/bin/env bash
set -eu

docker_sync_file=${1-""}
devbox_root="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../..")"

if [[ -z "${devbox_root}" || ! -d "${devbox_root}" || -z "${docker_sync_file}" || ! -f "${docker_sync_file}" ]]; then
  echo "Unable to initialize docker-sync-health-checker. Exit."
  exit
fi

source "${devbox_root}/tools/system/require-once.sh"
require_once "${devbox_root}/tools/docker/docker-sync.sh"

watched_sync_names=$(get_config_file_sync_names "${docker_sync_file}")
working_dir=$(get_config_file_working_dir "${docker_sync_file}")
max_attempts=10
attempt_no=0

hanging_unison_hashes=()
process_name='unison'
cpu_percentage_threshold='95' # cpu percentage per logical core as unison if single-thread process
max_cycles_before_kill=3

function start_watch() {
  restart_required="0"
  while [ ${attempt_no} -le ${max_attempts} ]; do
    if [[ "$(is_main_healthchecker_process)" == "1" ]]; then
      handle_hanging_unison_proceses "${hanging_unison_hashes[*]}"
    fi

    for sync_name in ${watched_sync_names}; do
      # Clear log file once its size became over 10MB
      _LOG_SIZE_THRESHOLD=10485760
      if [[ $(stat -f %z "${working_dir}/${sync_name}.log") > $_LOG_SIZE_THRESHOLD ]]; then
        echo "" >"${working_dir}/${sync_name}.log"
      fi

      if [[ ! -f "${working_dir}/${sync_name}.pid" ]]; then
        restart_required="1"

        if [[ ! -f "${working_dir}/${sync_name}.log" ]]; then
          touch "${_working_dir}/${_sync_name}.log"
        fi
        echo "[$(date)] ### An error occurred during syncing files. Trying to restart docker-sync process (attempt #${attempt_no}). Please wait a few second. ###" >>"${working_dir}/${sync_name}.log"

        break
      fi
    done

    if [[ "${restart_required}" == "1" ]]; then
      attempt_no=$((attempt_no + 1))

      set +e

      stop_output=""

      stop_output=$(docker_sync_stop "${docker_sync_file}" "0")
      echo "${stop_output}" >>"${working_dir}/${sync_name}.log"

      for sync_name in ${watched_sync_names}; do
        output=""

        # split operation and log writing to avoid busy file handler error
        output=$(docker_sync_start "${docker_sync_file}" ${sync_name} "0" "0")
        echo "${output}" >>"${working_dir}/${sync_name}.log"

        output=""
      done

      set -e

      if [[ "${output}" != "" ]]; then
        echo "${output}" >>"${working_dir}/${sync_name}.log"
      fi

      echo "[$(date)] ### Sync recovery successfully finished. ###" >>"${working_dir}/${sync_name}.log"

      restart_required="0"
    else
      attempt_no=0
    fi

    sleep 10
  done

  echo "### Docker-sync restarting failed after ${attempt_no} attempts. ###" >>"${working_dir}/${sync_name}.log"
  echo "### This case should be investigated. Please contact DevBox guys. ###" >>"${working_dir}/${sync_name}.log"
}

function is_main_healthchecker_process() {
  _first_process_pid=$(ps aux | grep "docker-sync-health-checker.sh" | grep -v 'grep' | awk -F" " '{print $2}' | sort | head -n 1)
  if [[ ${_first_process_pid} == $$ ]]; then
    echo "1"
  fi

  echo "0"
}

function handle_hanging_unison_proceses() {
  hanging_unison_hashes=$1

  _cycle_possible_hanging_unison_pids=$(ps aux | grep "${process_name} " | grep -v grep | awk -F" " '{if ($3 >= '${cpu_percentage_threshold}') print $2}')
  if [[ -z "${_cycle_possible_hanging_unison_pids}" ]]; then
    if [[ -n "${hanging_unison_hashes}" ]]; then
      show_success_message "No process found with high CPU utilization, clear unison reset list"
      hanging_unison_hashes=()
    fi
    return 0
  fi

  local _cycle_possible_hanging_unison_hashes=()

  for _unison_pid in ${_cycle_possible_hanging_unison_pids}; do
    # there is no proper way to detect process is actually hanging
    # so we calculate average cpu usage during 3 seconds
    # this is required to provide more accurate value and reduce influence of instantaneous values
    # in case avg cpu usage greater than ${cpu_percentage_threshold} value after ${max_cycles_before_kill} - we kill such process as hanging, further health-checked logic will restart it from scratch

    local _reset_candidate_confirmed="1"
    local _metric_counter=0
    while [ ${_metric_counter} -lt 3 ]; do
      _pid_cpu_percentage=$(ps aux | grep "${_unison_pid}" | grep -v -E "grep|awk" | awk -F" " '{if ($2 = '${_unison_pid}') print int($3)}')
      show_warning_message "PID '${_unison_pid}', CPU usage ${_metric_counter}:  '${_pid_cpu_percentage}'"
      if [[ ${_pid_cpu_percentage} < ${cpu_percentage_threshold} ]]; then
        _reset_candidate_confirmed="0"
        break
      fi
      _metric_counter=$((_metric_counter + 1))
      sleep 1
    done

    if [[ "${_reset_candidate_confirmed}" == "1" ]]; then
      show_warning_message "Unison reset candidate: PID '${_unison_pid}'"

      local _existing_hash=''
      for _hash in "${hanging_unison_hashes[@]}"; do
        if [[ -n $(echo "${_hash}" | grep "^${_unison_pid}:") ]]; then
          _existing_hash=${_hash}
          break
        fi
      done

      if [[ -n ${_existing_hash} ]]; then
        _cycle_num=$(($(echo "${_existing_hash}" | sed 's/.*://')+1))
        if [[ ${_cycle_num} < ${max_cycles_before_kill} ]]; then
          _cycle_possible_hanging_unison_hashes[${#_cycle_possible_hanging_unison_hashes[@]}]="${_unison_pid}:${_cycle_num}"
        else
          if [[ -n $(ps -eo pid | grep ${_unison_pid}) ]]; then
            show_warning_message "Killing PID '${_unison_pid}' as its CPU over the threshold '${cpu_percentage_threshold}' for '${max_cycles_before_kill}' cycles"
            # remove killed pid from the candidate list
            _tmp_hanging_unison_hashes=()
            for _index in "${!hanging_unison_hashes[@]}"; do
              if [[ ! "${hanging_unison_hashes[_index]}" =~ ^${_unison_pid}: ]];then
                _tmp_hanging_unison_hashes+=("${hanging_unison_hashes[_index]}")
              fi
            done
            hanging_unison_hashes=("${_tmp_hanging_unison_hashes[@]}")
            kill -15 ${_unison_pid}
          fi
        fi
      else
        _cycle_possible_hanging_unison_hashes[${#_cycle_possible_hanging_unison_hashes[@]}]="${_unison_pid}:1"
      fi
    else
      show_success_message "CPU utilization normalized for PID '${_unison_pid}', reset not required"
      # remove normalized pid from the candidate list
      _tmp_hanging_unison_hashes=()
        for _index in "${!hanging_unison_hashes[@]}"; do
          if [[ ! "${hanging_unison_hashes[_index]}" =~ ^${_unison_pid}: ]];then
            _tmp_hanging_unison_hashes+=("${hanging_unison_hashes[_index]}")
          fi
        done
        hanging_unison_hashes=("${_tmp_hanging_unison_hashes[@]}")
    fi
  done

  hanging_unison_hashes=("${_cycle_possible_hanging_unison_hashes[@]}")
}

start_watch
