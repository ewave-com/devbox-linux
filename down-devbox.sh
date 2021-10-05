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

require_once "${devbox_root}/tools/main.sh"
require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/menu/select-down-type.sh"
require_once "${devbox_root}/tools/menu/select-project.sh"

_selected_project=${1-""}
_selected_down_type=""

# Down preselected project(s) if script argument given
if [[ -n "${_selected_project}" ]]; then
  if [[ "${_selected_project}" == "all" ]]; then
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

start_docker_if_not_running

case $_selected_down_type in
"stop_one")
  if [[ -z "${_selected_project}" ]]; then
    select_project_menu "_selected_project"
  fi
  stop_devbox_project "${_selected_project}"
  ;;
"down_one")
  if [[ -z "${_selected_project}" ]]; then
    select_project_menu "_selected_project"
  fi
  down_devbox_project "${_selected_project}"
  ;;
"down_and_clean_one")
  if [[ -z "${_selected_project}" ]]; then
    select_project_menu "_selected_project"
  fi
  down_and_clean_devbox_project "${_selected_project}"
  ;;
"stop_all")
  stop_devbox_all
  ;;
"down_all")
  down_devbox_all
  ;;
"down_and_clean_all")
  down_and_clean_devbox_all
  ;;
"docker_destroy")
  docker_destroy
  ;;
*)
  show_error_message "Unable to parse your selection."
  exit 1
  ;;
esac

show_success_message
show_success_message "Thank you for using DevBox and have a nice day!"

cat "${devbox_root}/tools/print/done.txt"
