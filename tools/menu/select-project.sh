#!/usr/bin/env bash

require_once ${devbox_root}/tools/system/constants.sh
require_once ${devbox_root}/tools/system/output.sh
require_once ${devbox_root}/tools/project/all-projects.sh
require_once ${devbox_root}/tools/menu/abstract-select-menu.sh

############################ Public functions ############################

select_project_menu() {
  local _return_into_var=${1-"selected_project"}

  echo "----------------------------------------------"
  echo -e " * * * * * * * $GREEN Select project $SET* * * * * * * * "
  echo "----------------------------------------------"

  local _options_str
  _options_str="[Exit] $(get_project_list ' ')"

  local _sel_project
  select_menu_item "${_options_str[@]}" "_sel_project" " "

  if [[ -z "${_sel_project}" || "${_sel_project}" == "[Exit]" ]]; then
    show_success_message "No project selected. Exiting."
    exit 0
  fi

  eval ${_return_into_var}="${_sel_project}"
}

############################ Public functions end ############################
