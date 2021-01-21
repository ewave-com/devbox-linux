#!/usr/bin/env bash
set -eux

devbox_root=${1-""}
docker_sync_file=${2-""}

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

restart_required="0"
while [ ${attempt_no} -le ${max_attempts} ]; do
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
    (attempt_no++)

    set +e

    stop_output=""
    stop_output=(docker_sync_stop "${docker_sync_file}")
    echo "${stop_output}" >>"${working_dir}/${sync_name}.log"

    for sync_name in ${watched_sync_names}; do
      output=""

      # split operation and log writing to avoid busy file handler error
      output=(docker_sync_start "${docker_sync_file}" ${sync_name} "0" "0")
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
