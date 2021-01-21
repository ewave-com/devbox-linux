#!/usr/bin/env bash
set -eux

devbox_root=${1-""}
docker_sync_file=${2-""}

source "${devbox_root}/tools/system/require-once.sh"
require_once "${devbox_root}/tools/docker/docker-sync.sh"

if [[ -z "${devbox_root}" || ! -d "${devbox_root}" || -z "${docker_sync_file}" || ! -f "${docker_sync_file}" ]]; then
  echo "Unable to initialize docker-sync-health-checker. Exit."
  exit;
fi

watched_sync_names=$(get_config_file_sync_names "${docker_sync_file}")
working_dir=$(get_config_file_working_dir "${docker_sync_file}")
max_attempts=10
attempt_no=0

while [ ${attempt_no} -le ${max_attempts} ]
do
  for sync_name in ${watched_sync_names}; do
    if [[ ! -f "${working_dir}/${sync_name}.pid" ]]; then

      attempt_no=$((${attempt_no}+1))
      if [[ -f "${working_dir}/${sync_name}.log" ]]; then
        echo "########## An error occurred during syncing files. Trying to restart docker-sync process (attempt #${attempt_no}). Please wait a few second. ##########" >> "${working_dir}/${sync_name}.log"
      fi

      docker_sync_stop "${docker_sync_file}" "1" "0" && docker_sync_start "${docker_sync_file}" "1" "0"

      echo "########## Docker-sync successfully restarted. Continue working. ##########" >> "${working_dir}/${sync_name}.log"
      attempt_no=0
    fi
  done

  sleep 10
done

echo "########## Docker-sync restarting failed after ${attempt_no} attempts. ##########" >> "${working_dir}/${sync_name}.log"
echo "########## This case should be investigated. Please contact DevBox guys. ##########" >> "${working_dir}/${sync_name}.log"
