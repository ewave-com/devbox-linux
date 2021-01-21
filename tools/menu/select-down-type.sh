#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/menu/abstract-select-menu.sh"

############################ Public functions ############################

function select_down_type_menu() {
  local _return_into_var=${1-"selected_down_type"}

  draw_menu_header "Stop project menu"

  local _options_str="Stop 1 project,Stop ALL projects,Down and clean 1 project,Down and clean all projects,Destroy docker data[for emergency case],[Exit]"

  local _selected_type
  select_menu_item "${_options_str[@]}" "_selected_type"

  if [[ -z "${_selected_type}" || "${_selected_type}" == "[Exit]" ]]; then
    show_success_message "Exiting selected."
    exit 0
  fi

  if [[ "${_selected_type}" == "Stop 1 project" ]]; then
    _selected_type='stop_one'
  elif [[ "${_selected_type}" == "Stop ALL projects" ]]; then
    _selected_type='stop_all'
  elif [[ "${_selected_type}" == "Down and clean 1 project" ]]; then
    _selected_type='down_and_clean_one'
  elif [[ "${_selected_type}" == "Down and clean all projects" ]]; then
    _selected_type='down_and_clean_all'
  elif [[ "${_selected_type}" == "Destroy docker data[for emergency case]" ]]; then
    _selected_type='docker_destroy'
  fi

  draw_menu_footer

  eval ${_return_into_var}="${_selected_type}"
}

############################ Public functions end ############################
