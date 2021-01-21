#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/menu/abstract-select-menu.sh"
require_once "${devbox_root}/tools/docker/docker-sync.sh"

############################ Public functions ############################

function select_project_sync_name_menu() {
  local _selected_project=${1-""}
  local _return_into_var=${2-"_selected_sync_name"}

  if [[ -z "${_selected_project}" ]]; then
    show_error_message "Project name can not be empty to select sync"
    exit 1
  fi

  init_selected_project "${_selected_project}"

  draw_menu_header "Project sync names"

  _sync_names="$(get_directory_sync_names "${project_up_dir}")"

  local _options_str="[Exit],All,${_sync_names}"

  local _selected_item
  select_menu_item "${_options_str[@]}" "_selected_item"

  if [[ -z "${_selected_item}" || "${_selected_item}" == "[Exit]" ]]; then
    show_success_message "Exiting selected."
    exit 0
  fi

  if [[ "${_selected_item}" == "All" ]]; then
    _selected_item="all"
  fi

  draw_menu_footer

  eval ${_return_into_var}="${_selected_item}"
}

############################ Public functions end ############################
