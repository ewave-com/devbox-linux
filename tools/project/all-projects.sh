#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/project/project-state.sh"

############################ Public functions ############################

function get_project_list() {
  local _delimiter=${1-","}
  local _project_list

  if [[ "${os_type}" == "macos" ]]; then
    # MacOs specific, use "gfind" for "-printf" option
    _project_list="$(gfind ${devbox_projects_dir}/ -maxdepth 1 -mindepth 1 -type d ! -path "*/archived_projects" -printf '%f\n' | sort -n | sed 's/ /£/' | tr '\n' "${_delimiter}")"
  elif [[ "${os_type}" == "linux" ]]; then
    _project_list="$(find ${devbox_projects_dir}/ -maxdepth 1 -mindepth 1 -type d ! -path "*/archived_projects" -printf '%f\n' | sort -n | sed 's/ /£/' | tr '\n' "${_delimiter}")"
  fi

  echo "${_project_list}"
}

# 1 - true, 0 - false
function is_project_started() {
  local _selected_project=${1-''}
  local _fast_check=${2-'0'}

  if [ -z "${_selected_project}" ]; then
    show_error_message "Unable to check if project is started. Project name cannot be empty."
    exit 1
  fi

  local _project_dir="${devbox_projects_dir}/${_selected_project}"
  if [[ $(is_project_configured $_selected_project) != "1" ]]; then
    show_error_message "Project '${_selected_project}' is not configured. Please ensure file '${_project_dir}/.env' exists and has proper configuration values."
    show_error_message "You can copy 'config/project-defaults.env' into your project directory as '.env' and modify it as you need before starting."
    exit 1
  fi

  local _project_up_dir="${_project_dir}/docker-up"
  if [[ ! -d "${_project_up_dir}" ]]; then
    echo "0"
    return
  fi

  if [[ $(is_state_file_exists "${_project_up_dir}") == "0" ]] || [[ $(get_state_last_project_status "${_project_up_dir}") != "started" ]]; then
    echo "0"
    return
  fi

  local _dotenv_project_name
  _dotenv_project_name=$(dotenv_get_param_value 'PROJECT_NAME' "${_project_dir}/.env")
  local _has_main_dotenv_file
  _has_main_dotenv_file=$([[ -f "${_project_up_dir}/.env" ]] && echo "1" || echo "0")
  local _has_project_running_containers
  _has_project_running_containers=$([[ "${_fast_check}" == "0" ]] && echo $(is_docker_container_running "${_dotenv_project_name}_" "0") || echo "1")
  local _docker_files_count
  _docker_files_count=$(find "${_project_up_dir}" -mindepth 1 -maxdepth 1 -name "docker-*.yml" | awk '{print length}')
  local _config_dirs_count
  _config_dirs_count=$(find "${_project_up_dir}" -mindepth 1 -maxdepth 1 -type d | awk '{print length}')

  if [[ "${_has_main_dotenv_file}" == "1" && "${_has_project_running_containers}" == "1" && ${_docker_files_count} > 0 && ${_config_dirs_count} > 0 ]]; then
    echo "1"
  else
    echo "0"
  fi
}

# 1 - true, 0 - false
function ensure_project_configured() {
  local _selected_project=${1-''}
  if [ -z "${_selected_project}" ]; then
    show_error_message "Unable to check if project is configured. Project name cannot be empty."
    exit 1
  fi

  local _failed="0"

  local _project_dir="${devbox_projects_dir}/${_selected_project}"
  if [[ ! -d "${_project_dir}" || ! -f "${_project_dir}/.env" ]]; then
    show_warning_message "Project '${_selected_project}' is not configured. Project file '.env' file is missing"
    _failed="1"
  fi

  if [[ "${_failed}" == "0" ]]; then
    # read project name from the initial file without generating of the final .env
    _dotenv_project_name=$(dotenv_get_param_value PROJECT_NAME "${_project_dir}/.env")
    if [[ -z "${_dotenv_project_name}" ]]; then
      show_warning_message "Project '${_selected_project}' is not configured. At least param 'PROJECT_NAME' is not configured in the '${_project_dir}/.env'"
      exit 1
    fi
  fi

  if [[ "${_failed}" == "1" ]]; then
    show_error_message "Project '${_selected_project}' is not configured. Please ensure file '${_project_dir}/.env' exists and has proper configuration values."
    show_error_message "You can copy 'config/project-defaults.env' into your project directory as '.env' and modify it as you need before starting."
    exit 1
  fi
}

# 1 - true, 0 - false
function is_project_configured() {
  local _selected_project=${1-''}
  if [ -z "${_selected_project}" ]; then
    show_error_message "Unable to check if project is configured. Project name cannot be empty."
    exit 1
  fi

  local _project_dir="${devbox_projects_dir}/${_selected_project}"
  if [[ ! -d "${_project_dir}" || ! -f "${_project_dir}/.env" ]]; then
    echo "0"
    return
  fi

  # read project name from the initial file without generating of the final .env
  _dotenv_project_name=$(dotenv_get_param_value PROJECT_NAME "${_project_dir}/.env")
  if [[ -z "${_dotenv_project_name}" ]]; then
    echo "0"
    return
  fi

  echo "1"
}

############################ Public functions end ############################
