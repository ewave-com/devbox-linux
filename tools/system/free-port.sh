#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

# Function which find free port for mysql service
function get_available_mysql_port() {
  local _port
  _port=$(find_port_by_regex "340[0-9]{1}")

  if [[ -z "${_port}" ]]; then
    _port=3400
  else
    _port=$((_port + 1))
  fi

  echo ${_port}
}

# Function which checks if mysql port is available to be exposed
function ensure_mysql_port_is_available() {
  local _checked_port=${1-""}
  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check mysql port. Port number argument cannot be empty"
    exit 1
  fi

  # Check the given mysql port is free
  local _used_port
  _used_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_used_port}" ]]; then
    show_error_message "MYSQL port ${_checked_port} is in use"
    show_error_message "Please set port CONTAINER_MYSQL_PORT to another value of set it empty for autocompleting in '${project_dir}/.env' file"
    exit 1
  fi

  if [[ "${_checked_port}" < "3306" || "${_checked_port}" > "3499" ]]; then
    show_error_message "MYSQL port must be configured in range 3306-3499. Value '${_checked_port}' given. Please update value in your '${project_dir}/.env' file."
    exit 1
  fi
}

# Function which find free port for elasticsearch service
function get_available_elasticsearch_port() {
  local _port
  _port=$(find_port_by_regex "920[0-9]{1}")

  if [[ -z "${_port}" ]]; then
    _port=9200
  else
    _port=$((_port + 1))
  fi

  echo ${_port}
}

# Function which checks if elasticsearch port is available to be exposed
function ensure_elasticsearch_port_is_available() {
  local _checked_port=${1-""}
  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check elasticsearch port. Port number argument cannot be empty"
    exit 1
  fi

  local _used_port
  _used_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_used_port}" ]]; then
    show_error_message "ElasticSearch port ${_checked_port} is in use"
    show_error_message "Please set port CONTAINER_ELASTICSEARCH_PORT to another value of set it empty for autocompleting in '${project_dir}/.env' file"
    exit 1
  fi

  if [[ "${_checked_port}" < "9200" || "${_checked_port}" > "9399" ]]; then
    show_error_message "ElasticSearch port must be configured in range 9200-9399. Value '${_checked_port}' given. Please update value in your '${project_dir}/.env' file."
    exit 1
  fi
}

# Function which find free ssh port for website
function get_available_website_ssh_port() {
  local _port
  _port=$(find_port_by_regex "230[0-9]{1}")

  if [[ -z "${_port}" ]]; then
    _port=2300
  else
    _port=$((_port + 1))
  fi

  echo ${_port}
}

# Function which checks if website ssh port is available to be exposed
function ensure_website_ssh_port_is_available() {
  local _checked_port=${1-""}
  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check website ssh port. Port number argument cannot be empty"
    exit 1
  fi

  # Check the given elasticsearch port is free
  local _used_port
  _used_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_used_port}" ]]; then
    show_error_message "Website ssh port ${_checked_port} is in use"
    show_error_message "Please set port CONTAINER_WEB_SSH_PORT to another value of set it empty for autocompleting in '${project_dir}/.env' file"
    exit 1
  fi

  if [[ "${_checked_port}" < "2300" || "${_checked_port}" > "2499" ]]; then
    show_error_message "Website ssh port must be configured in range 2300-2499. Value '${_checked_port}' given. Please update value in your '${project_dir}/.env' file."
    exit 1
  fi
}

# Function which check port is available to be exposed
function ensure_port_is_available() {
  local _checked_port=${1-""}

  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check port availability. Port number argument cannot be empty"
    exit 1
  fi

  local _used_port
  _used_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_used_port}" ]]; then
    show_error_message "Unable to allocate port '${_checked_port}' as it is already in use. Please free the port and try again."
    exit 1
  fi
}

############################ Public functions end ############################

############################ Local functions ############################

function find_port_by_regex() {
  local _port_mask=${1-""}

  if [[ -z ${_port_mask} ]]; then
    show_error_message "Unable to find available port by empty mask."
    exit 1
  fi

  local _port_mask
  local _port
  # if mask is only numbers - prepend possible hosts to clarify output
  if [[ ! "${_port_mask}" =~ ^: ]]; then
    if [[ "${os_type}" == "macos" ]]; then
      # MacOs specific, Linux: port separator = semicolon, MacOs: port separator = dot
      _port_mask="'(\*\.${_port_mask}\s)|(:::${_port_mask}\s)|(0\.0\.0\.0:${_port_mask}\s)|(127\.0\.0\.1:${_port_mask}\s)"
    elif [[ "${os_type}" == "linux" ]]; then
      # Linux: port separator = semicolon, MacOs: port separator = dot
      _port_mask="'(\*\:${_port_mask}\s)|(:::${_port_mask}\s)|(0\.0\.0\.0:${_port_mask}\s)|(127\.0\.0\.1:${_port_mask}\s)"
    fi
  fi

  if [[ "${os_type}" == "macos" ]]; then
    _port=$(sudo netstat -anvp tcp | grep -E "${_port_mask}" | grep "LISTEN" | awk '{print $4}' | grep -v "::1:" | sed 's/.*://' | sort -g -r | head -n 1)
  elif [[ "${os_type}" == "linux" ]]; then
    _port=$(sudo netstat -tlpn | grep -E "${_port_mask}" | grep "LISTEN" | awk '{print $4}' | grep -v "::1:" | sed 's/.*://' | sort -g -r | head -n 1)
  fi

  echo ${_port}
}

############################ Local functions end ############################
