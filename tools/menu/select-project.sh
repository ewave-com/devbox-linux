#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/project/all-projects.sh"
require_once "${devbox_root}/tools/menu/abstract-select-menu.sh"

############################ Public functions ############################

function select_project_menu() {
  local _return_into_var=${1-"selected_project"}

  draw_menu_header "Select project"

  _project_list="$(get_project_list)"
  if [[ "${_project_list}" == '' ]]; then
    show_error_message "Projects not found in directory ${devbox_projects_dir}. Please create project folder with required configuration files and try again."
    exit 0
  fi

  # add project status info to the project menu, after selecting remove appendixes from string
  local _project_list_arr=()
  for _project_name in $(echo "${_project_list}" | tr ',' ' '); do
    if [[ "$(is_project_configured ${_project_name})" == "0" ]]; then
      _project_name="${_project_name} [not configured]"
    elif [[ "$(is_project_started ${_project_name} '1')" == "1" ]]; then
      _project_name="${_project_name} [started]"
    fi

    _project_list_arr[${#_project_list_arr[@]}]="${_project_name}"
  done

  _project_list=$(
    IFS=,
    echo "${_project_list_arr[*]}"
  )

  local _options_str
  _options_str="[Exit],${_project_list}"

  local _sel_project
  select_menu_item "${_options_str[@]}" "_sel_project"

  if [[ -z "${_sel_project}" || "${_sel_project}" == "[Exit]" ]]; then
    show_success_message "No project selected. Exiting."
    exit 0
  fi

  _sel_project=$(echo "${_sel_project}" | sed 's/\ \[started\]//g' | sed "s/\ \[not\ configured\]//g")

  draw_menu_footer

  eval ${_return_into_var}="${_sel_project}"
}

############################ Public functions end ############################
