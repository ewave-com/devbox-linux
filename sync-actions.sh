#!/usr/bin/env bash
set -eu       # Normal working mode
#set -eux     # Verbose debug mode

# 'realpath' might be not installed
if [[ ! -z "$(which realpath)" ]]; then
  devbox_root=$(realpath $(dirname "${BASH_SOURCE[0]}"))
else
  devbox_root=`dirname "$0"`
  [[ "${devbox_root}" == "." ]] && devbox_root="${PWD}"
fi
export devbox_root

source "${devbox_root}/tools/system/require-once.sh"

require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/menu/select-sync-action.sh"
require_once "${devbox_root}/tools/menu/select-project-sync-name.sh"
require_once "${devbox_root}/tools/menu/select-project.sh"
require_once "${devbox_root}/tools/project/project-main.sh"
require_once "${devbox_root}/tools/sync-main.sh"

_selected_project=${1-""}
_selected_sync_action=""
_selected_sync_name=""

# Down preselected project(s) if script argument given
if [[ -n "${_selected_project}" ]]; then
  _selected_sync_action="restart_sync"
fi

# Interactive menu to choose the next activity with devbox
if [[ -z "${_selected_sync_action}" ]]; then
  select_sync_action_menu "_selected_sync_action"
fi

start_docker_if_not_running

case $_selected_sync_action in
"start_sync")
  if [[ -z "${_selected_project}" ]]; then
    select_project_menu "_selected_project"
  fi
  start_sync "${_selected_project}"
  ;;
"stop_sync")
  if [[ -z "${_selected_project}" ]]; then
    select_project_menu "_selected_project"
  fi
  stop_sync "${_selected_project}"
  ;;
"restart_sync")
  if [[ -z "${_selected_project}" ]]; then
    select_project_menu "_selected_project"
  fi
  restart_sync "${_selected_project}"
  ;;
"show_logs")
  if [[ -z "${_selected_project}" ]]; then
    select_project_menu "_selected_project"
  fi
  if [[ -z "${_selected_sync_name}" ]]; then
    select_project_sync_name_menu ${_selected_project} '_selected_sync_name'
  fi
  open_log_window "${_selected_project}" "${_selected_sync_name}"
  ;;
*)
  show_error_message "Unknown sync action."
  exit 1
  ;;
esac

show_success_message "Sync operation finished!"
