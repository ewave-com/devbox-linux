#!/usr/bin/env bash

export devbox_root=$(pwd)

# import global variables
require_once ${devbox_root}/tools/system/constants.sh
# import output functions (print messages)
require_once ${devbox_root}/tools/system/output.sh
# import infrastructure functions
require_once ${devbox_root}/tools/docker/infrastructure.sh
# import main project functions entrypoint
require_once ${devbox_root}/tools/project/project-main.sh
# import common functions for all projects structure
require_once ${devbox_root}/tools/project/all-projects.sh
# import platform-tools functions
require_once ${devbox_root}/tools/project/platform-tools.sh
# import functions to show project information after start
require_once ${devbox_root}/tools/print/print-project-info.sh

############################ Public functions ############################

start_devbox_project() {
  local _selected_project=${1-""}

  show_success_message ">> Starting DevBox project \"${_selected_project}\""

  # initialize basic project variables and directories
  init_selected_project "${_selected_project}"

  if [[ "$(is_project_started ${_selected_project})" = "1" ]]; then
    show_warning_message "Project \"${_selected_project}\" is already started."
    show_warning_message "Please ensure selected project is correct, or stop it and try to start again."
    exit 1
  fi

  show_success_message ">> Preparing project .env file and variables"
  # Prepare all required variables from .env
  dotenv_prepare_project_variables "1"

  show_success_message ">> Starting common infrastructure."
  # Start common infra services, e.g. portainer, nginx-reverse-proxy, mailer, etc.
  start_infrastructure

  show_success_message ">> Preparing project configs and starting docker services"
  # Prepare all required configs and start project services
  start_project

  show_success_message ">> Project \"${_selected_project}\" was successfully started"

  # Print final project info
  print_info

  # Run platform tools menu inside web-container
  run_platform_tools

  # Unset all used variables
  dotenv_unset_variables
}

stop_devbox_project() {
  local _selected_project=${1-""}

  if [[ "$(is_project_started ${_selected_project})" == "0" ]]; then
      show_success_message ">> DevBox project \"${_selected_project}\" is already stopped"
      return 0
  fi

  show_success_message ">> Stopping DevBox project \"${_selected_project}\""

  show_success_message ">> Stopping docker services and cleaning up configs"

  # initialize basic project variables and directories
  init_selected_project "${_selected_project}"

  stop_project

  show_success_message ">> Project \"${_selected_project}\" was successfully stopped"
}

stop_devbox() {
  show_success_message "> Stopping all DevBox projects"

  # Stop all project containers
  for selected_project in $(get_project_list "\n"); do
    stop_devbox_project "${selected_project}"
  done

  show_success_message "> Stopping common infrastructure."
  # Stop common infrastructure services images
  down_infrastructure

  show_success_message "> All DevBox projects were successfully stopped"
}

# todo implement or not?
#kill_project() {}

############################ Public functions end ############################
