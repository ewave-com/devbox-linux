#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/menu/abstract-select-menu.sh"

############################ Public functions ############################

function select_sync_action_menu() {
  local _return_into_var=${1-"selected_sync_action"}

  draw_menu_header "Sync action"

  local _options_str="[Exit],Restart sync,Stop sync,Start sync,Show logs"

  local _selected_type
  select_menu_item "${_options_str[@]}" "_selected_type"

  if [[ -z "${_selected_type}" || "${_selected_type}" == "[Exit]" ]]; then
    show_success_message "Exiting selected."
    exit 0
  fi

  if [[ "${_selected_type}" == "Restart sync" ]]; then
      _selected_type='restart_sync'
  elif [[ "${_selected_type}" == "Stop sync" ]]; then
    _selected_type='stop_sync'
  elif [[ "${_selected_type}" == "Start sync" ]]; then
    _selected_type='start_sync'
  elif [[ "${_selected_type}" == "Show logs" ]]; then
    _selected_type='show_logs'
  fi

  draw_menu_footer

  eval ${_return_into_var}="${_selected_type}"
}

############################ Public functions end ############################
