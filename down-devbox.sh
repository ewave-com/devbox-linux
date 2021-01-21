#!/usr/bin/env bash
set -eu

export devbox_root=$(pwd)
source "${devbox_root}/tools/system/require-once.sh"

require_once "${devbox_root}"/tools/main.sh
require_once ${devbox_root}/tools/system/output.sh
require_once ${devbox_root}/tools/menu/select-down-type.sh
require_once ${devbox_root}/tools/menu/select-project.sh

_selected_project=${1-""}
_selected_down_type=""

# Down preselected project(s) if script argument given
if [[ -n "${_selected_project}" ]]; then
  if [[ "${_selected_project}" = "all" ]]; then
    _selected_down_type="stop_all"
    _selected_project=""
  else
    _selected_down_type="stop_one"
  fi
fi

# Interactive menu to choose the next activity with devbox
if [[ -z "${_selected_down_type}" ]]; then
  select_down_type_menu "_selected_down_type"
fi

if [[ "${_selected_down_type}" = "stop_one" ]]; then
  if [[ -z "${_selected_project}" ]]; then
    select_project_menu "_selected_project"
  fi

  stop_devbox_project "${_selected_project}"
elif [[ "${_selected_down_type}" = "stop_all" ]]; then
  stop_devbox
else
  show_error_message "Unable to parse your selection."
  exit 1
fi

show_success_message "Thank you for using DevBox and have a nice day!"

cat ${devbox_root}/tools/print/done.txt
