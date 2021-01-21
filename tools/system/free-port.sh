#!/usr/bin/env bash

require_once ${devbox_root}/tools/system/output.sh

############################ Public functions ############################

# Function which find free port for mysql service
get_available_mysql_port() {
  local _port
  _port=$(find_port_by_regex "340[0-9]{1}")

  if [[ -z "${_port}" ]]; then
    _port=3400
  else
    _port=$((_port + 1))
  fi

  echo ${_port}
}

# Function which find free port for mysql service
ensure_mysql_port_is_available() {
  local _checked_port=${1-""}
  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check mysql port. Port number argument cannot be empty"
    exit 1
  fi

  # Check the given mysql port is free
  local _current_mysql_port
  _current_mysql_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_current_mysql_port}" ]]; then
    show_error_message "MYSQL port ${_checked_port} is in use"
    show_error_message "Please set port CONTAINER_MYSQL_PORT to another value of set it empty for autocompleting in ${project_dir}/.env file"
    exit 1
  fi

  if [[ "${_checked_port}" < "3306" || "${_checked_port}" > "3499" ]]; then
    show_error_message "MYSQL port must be configured in range 3306-3499. Value \"${_checked_port}\" given. Please update value in your ${project_dir}/.env file."
    exit 1
  fi

  return "0"
}

# Function which find free port for elasticsearch service
get_available_elasticsearch_port() {
  local _port
  _port=$(find_port_by_regex "920[0-9]{1}")

  if [[ -z "${_port}" ]]; then
    _port=9200
  else
    _port=$((_port + 1))
  fi

  echo ${_port}
}

# Function which find free port for elasticsearch service
ensure_elasticsearch_port_is_available() {
  local _checked_port=${1-""}
  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check elasticsearch port. Port number argument cannot be empty"
    exit 1
  fi

  # Check the given elasticsearch port is free
  local _current_port
  _current_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_current_port}" ]]; then
    show_error_message "ElasticSearch port ${_checked_port} is in use"
    show_error_message "Please set port CONTAINER_ELASTICSEARCH_PORT to another value of set it empty for autocompleting in ${project_dir}/.env file"
    exit 1
  fi

  if [[ "${_checked_port}" < "9200" || "${_checked_port}" > "9399" ]]; then
    show_error_message "ElasticSearch port must be configured in range 9200-9399. Value \"${_checked_port}\" given. Please update value in your ${project_dir}/.env file."
    exit 1
  fi

  return "0"
}

# Function which find free port for mysql service
get_available_ssh_port() {
  local _port
  _port=$(find_port_by_regex "230[0-9]{1}")

  if [[ -z "${_port}" ]]; then
    _port=2300
  else
    _port=$((_port + 1))
  fi

  echo ${_port}
}

# Function which find free port for mysql service
ensure_ssh_port_is_available() {
  local _checked_port=${1-""}
  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check Web SSH port. Port number argument cannot be empty"
    exit 1
  fi

  local _current_port
  _current_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_current_port}" ]]; then
    show_error_message "SSH port ${_checked_port} is in use"
    show_error_message "Please set port CONTAINER_WEB_SSH_PORT to another value of set it empty for autocompleting in ${project_dir}/.env file"
    exit 1
  fi

  if [[ "${_checked_port}" < "2300" || "${_checked_port}" > "2499" ]]; then
    show_error_message "SSH port must be configured in range 2300-2499. Value \"${_checked_port}\" given. Please update value in your ${project_dir}/.env file."
    exit 1
  fi

  return "0"
}

# Function which find free port for mysql service
get_available_unison_port() {
  local _port
  _port=$(find_port_by_regex "700[0-9]{1}")

  if [[ -z "${_port}" ]]; then
    _port=7000
  else
    _port=$((_port + 1))
  fi

  echo ${_port}
}

# Function which find free port for unison service
ensure_unison_port_is_available() {
  local _checked_port=${1-""}
  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check Web Unison port. Port number argument cannot be empty"
    exit 1
  fi

  local _current_port
  _current_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_current_port}" ]]; then
    show_error_message "Unison port ${_checked_port} is in use"
    show_error_message "Please set port CONTAINER_WEB_UNISON_PORT to another value of set it empty for autocompleting in ${project_dir}/.env file"
    exit 1
  fi

  if [[ "${_checked_port}" < "7000" || "${_checked_port}" > "7200" ]]; then
    show_error_message "Unison port must be configured in range 7000-7200. Value \"${_checked_port}\" given. Please update value in your ${project_dir}/.env file."
    exit 1
  fi

  return "0"
}

############################ Public functions end ############################

############################ Local functions ############################

find_port_by_regex() {
  local _port_mask=${1-""}

  if [[ -z ${_port_mask} ]]; then
    show_error_message "Unable to find available port by empty mask."
    exit 1
  fi

  local _port_mask
  local _port
  # if mask is only numbers - prepend possible hosts to clarify output
  if [[ ! "${_port_mask}" =~ ^: ]]; then
    if [[ "${os_type}" = "macos" ]]; then
      # MacOs specific, Linux: port separator = semicolon, MacOs: port separator = dot
      _port_mask="'(\*\.${_port_mask}\s|:::${_port_mask}\s)|(0\.0\.0\.0:${_port_mask}\s)|(127\.0\.0\.1:${_port_mask}\s)"
      _port=$(sudo netstat -anvp tcp | grep -E "${_port_mask}" | grep "LISTEN" | awk '{print $4}' | grep -v "::1:" | sed 's/.*://' | sort -g -r | head -n 1)
    elif [[ "${os_type}" = "linux" ]]; then
      # Linux: port separator = semicolon, MacOs: port separator = dot
      _port_mask="'(\*\:${_port_mask}\s|:::${_port_mask}\s)|(0\.0\.0\.0:${_port_mask}\s)|(127\.0\.0\.1:${_port_mask}\s)"
      _port=$(sudo netstat -tlpn | grep -E "${_port_mask}" | grep "LISTEN" | awk '{print $4}' | grep -v "::1:" | sed 's/.*://' | sort -g -r | head -n 1)
    fi
  fi

  echo ${_port}
}

############################ Local functions end ############################
