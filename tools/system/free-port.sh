#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

# Function which find free port for mysql service
function get_available_mysql_port() {
  local _containers_port
  local _netstat_port

  _containers_port=$(find_port_across_docker_containers "34[0-9]{2}")
  _netstat_port=$(find_port_by_regex "34[0-9]{2}")

  local _result_port
  if [[ -z "${_netstat_port}" && -z "${_containers_port}" ]]; then
    _result_port=3400
  else
    # find highest port across docker containers ports and netstat ports by mask and allocate the next one
    _result_port=$(($(printf '%s\n' "${_containers_port}" "${_netstat_port}" | sort -g -r | head -n 1) + 1))
  fi

  echo "${_result_port}"
}

function get_mysql_port_from_existing_container() {
  local _container_name=${1-""}

  if [[ -z ${_container_name} ]]; then
    show_error_message "Unable to check mysql port from existing container. Container name cannot be empty"
    exit 1
  fi

  local _container_port
  _container_port=$(find_port_across_docker_containers "34[0-9]{2}" "${_container_name}")

  echo "${_container_port}"
}

# Function which checks if mysql port is available to be exposed
function ensure_mysql_port_is_available() {
  local _checked_port=${1-""}
  local _container_name=${2-""}
  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check mysql port. Port number argument cannot be empty"
    exit 1
  fi

  # Check the given mysql port is free
  local _used_port
  _used_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_used_port}" ]]; then
    _process_info=$(get_process_info_by_allocated_port ${_checked_port})
    # if container name given then skip error if the checked allocated port belongs to the same container
    if [[ -z "${_container_name}" || -z $(echo ${_process_info} | grep "${_container_name}") ]]; then
      show_error_message "MYSQL port ${_checked_port} is already allocated by process ${_process_info}"
      show_error_message "Please free the port, set port CONTAINER_MYSQL_PORT to another value of set it empty for autocompleting in '${project_dir}/.env' file"
      exit 1
    fi
  fi

  if [[ "${_checked_port}" < "3306" || "${_checked_port}" > "3499" ]]; then
    show_error_message "MYSQL port must be configured in range 3306-3499. Value '${_checked_port}' given. Please update value in your '${project_dir}/.env' file."
    exit 1
  fi
}

# Function which find free port for elasticsearch service
function get_available_elasticsearch_port() {
  local _containers_port
  local _netstat_port

  _containers_port=$(find_port_across_docker_containers "92[0-9]{2}")
  _netstat_port=$(find_port_by_regex "92[0-9]{2}")

  local _result_port
  if [[ -z "${_netstat_port}" && -z "${_containers_port}" ]]; then
    _result_port=9200
  else
    # find highest port across docker containers ports and netstat ports by mask and allocate the next one
    _result_port=$(($(printf '%s\n' "${_containers_port}" "${_netstat_port}" | sort -g -r | head -n 1) + 1))
  fi

  echo "${_result_port}"
}

function get_elasticsearch_port_from_existing_container() {
  local _container_name=${1-""}

  if [[ -z ${_container_name} ]]; then
    show_error_message "Unable to check elasticsearch port from existing container. Container name cannot be empty"
    exit 1
  fi

  local _container_port
  _container_port=$(find_port_across_docker_containers "92[0-9]{2}" "${_container_name}")

  echo "${_container_port}"
}

# Function which checks if elasticsearch port is available to be exposed
function ensure_elasticsearch_port_is_available() {
  local _checked_port=${1-""}
  local _container_name=${2-""}
  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check elasticsearch port. Port number argument cannot be empty"
    exit 1
  fi

  local _used_port
  _used_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_used_port}" ]]; then
    _process_info=$(get_process_info_by_allocated_port ${_checked_port})
    # if container name given then skip error if the checked allocated port belongs to the same container
    if [[ -z "${_container_name}" || -z $(echo ${_process_info} | grep "${_container_name}") ]]; then
      show_error_message "ElasticSearch port ${_checked_port} is already allocated by process ${_process_info}"
      show_error_message "Please free the port, set port CONTAINER_ELASTICSEARCH_PORT to another value of set it empty for autocompleting in '${project_dir}/.env' file"
      exit 1
    fi
  fi

  if [[ "${_checked_port}" < "9200" || "${_checked_port}" > "9399" ]]; then
    show_error_message "ElasticSearch port must be configured in range 9200-9399. Value '${_checked_port}' given. Please update value in your '${project_dir}/.env' file."
    exit 1
  fi
}

# Function which find free port for rabbitmq service
function get_available_rabbitmq_port() {
  local _containers_port
  local _netstat_port

  _containers_port=$(find_port_across_docker_containers "56[0-9]{2}")
  _netstat_port=$(find_port_by_regex "56[0-9]{2}")

  local _result_port
  if [[ -z "${_netstat_port}" && -z "${_containers_port}" ]]; then
    _result_port=5672
  else
    # find highest port across docker containers ports and netstat ports by mask and allocate the next one
    _result_port=$(($(printf '%s\n' "${_containers_port}" "${_netstat_port}" | sort -g -r | head -n 1) + 1))
  fi

  echo "${_result_port}"
}

function get_rabbitmq_port_from_existing_container() {
  local _container_name=${1-""}

  if [[ -z ${_container_name} ]]; then
    show_error_message "Unable to check rabbitmq port from existing container. Container name cannot be empty"
    exit 1
  fi

  local _container_port
  _container_port=$(find_port_across_docker_containers "56[0-9]{2}" "${_container_name}")

  echo "${_container_port}"
}

# Function which checks if rabbitmq port is available to be exposed
function ensure_rabbitmq_port_is_available() {
  local _checked_port=${1-""}
  local _container_name=${2-""}
  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check rabbitmq port. Port number argument cannot be empty"
    exit 1
  fi

  local _used_port
  _used_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_used_port}" ]]; then
    _process_info=$(get_process_info_by_allocated_port ${_checked_port})
    # if container name given then skip error if the checked allocated port belongs to the same container
    if [[ -z "${_container_name}" || -z $(echo ${_process_info} | grep "${_container_name}") ]]; then
      show_error_message "RabbitMQ port ${_checked_port} is already allocated by process ${_process_info}"
      show_error_message "Please free the port, set port CONTAINER_RABBITMQ_PORT to another value of set it empty for autocompleting in '${project_dir}/.env' file"
      exit 1
    fi
  fi

  if [[ "${_checked_port}" < "5600" || "${_checked_port}" > "5699" ]]; then
    show_error_message "RabbitMQ port must be configured in range 5600-5699. Value '${_checked_port}' given. Please update value in your '${project_dir}/.env' file."
    exit 1
  fi
}

# Function which find free ssh port for website
function get_available_website_ssh_port() {
  local _containers_port
  local _netstat_port

  _containers_port=$(find_port_across_docker_containers "23[0-9]{2}")
  _netstat_port=$(find_port_by_regex "23[0-9]{2}")

  local _result_port
  if [[ -z "${_netstat_port}" && -z "${_containers_port}" ]]; then
    _result_port=2300
  else
    # find highest port across docker containers ports and netstat ports by mask and allocate the next one
    _result_port=$(($(printf '%s\n' "${_containers_port}" "${_netstat_port}" | sort -g -r | head -n 1) + 1))
  fi

  echo "${_result_port}"
}

function get_website_ssh_port_from_existing_container() {
  local _container_name=${1-""}

  if [[ -z ${_container_name} ]]; then
    show_error_message "Unable to check website ssh port from existing container. Container name cannot be empty"
    exit 1
  fi

  local _container_port
  _container_port=$(find_port_across_docker_containers "23[0-9]{2}" "${_container_name}")

  echo "${_container_port}"
}

# Function which checks if website ssh port is available to be exposed
function ensure_website_ssh_port_is_available() {
  local _checked_port=${1-""}
  local _container_name=${2-""}
  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check website ssh port. Port number argument cannot be empty"
    exit 1
  fi

  # Check the given elasticsearch port is free
  local _used_port
  _used_port=$(find_port_by_regex "${_checked_port}")
  if [[ "${_checked_port}" == "${_used_port}" ]]; then
    _process_info=$(get_process_info_by_allocated_port ${_checked_port})
    # if container name given then skip error if the checked allocated port belongs to the same container
    if [[ -z "${_container_name}" || -z $(echo ${_process_info} | grep "${_container_name}") ]]; then
      show_error_message "Website ssh port ${_checked_port} is already allocated by process ${_process_info}"
      show_error_message "Please free the port, set port CONTAINER_WEB_SSH_PORT to another value of set it empty for autocompleting in '${project_dir}/.env' file"
      exit 1
    fi
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
    _process_info="$(get_process_info_by_allocated_port ${_checked_port})"
    show_error_message "Unable to allocate port '${_checked_port}' as it is already in use by process ${_process_info}. Please free the port and try again."
    exit 1
  fi
}

function get_process_info_by_allocated_port() {
  local _checked_port=${1-""}

  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check port allocation. Port number argument cannot be empty"
    exit 1
  fi

  _port_mask=$(get_port_full_search_mask ${_checked_port})
  local _pid
  local _pname
  if [[ "${os_type}" == "macos" ]]; then
    _pid=$(sudo netstat -anvp tcp | grep -E "${_port_mask}" | grep "LISTEN" | grep -v "::1:" | awk '{print $9}' | head -n 1)
    if [[ -n ${_pid} ]]; then
      _pname=$(ps -e -c -o comm ${_pid} | grep -v "COMM")
    fi
  elif [[ "${os_type}" == "linux" ]]; then
    _pid=$(sudo netstat -tlpn tcp | grep -E "${_port_mask}" | grep "LISTEN" | grep -v "::1:" | awk '{print $7}' | head -n 1 | cut -d'/' -f 1)
    if [[ -n ${_pid} ]]; then
      _pname=$(ps -c -o comm --no-headers -f ${_pid})
    fi
  fi

  if [[ -n ${_pid} && -n "${_pname}" ]]; then
    if [[ -n $(echo "${_pname}" | grep -i "docker") ]]; then
      _container_name=$(docker ps -a --filter="publish=${_checked_port}" --filter=status=running --format='{{.Names}}')
      echo "PID: ${_pid}; Process name: '${_pname}'; Docker container name: '${_container_name}'"
      return
    fi

    echo "PID: ${_pid}; Process name: '${_pname}'"
    return
  fi

  echo ""
}

function find_port_across_docker_containers() {
  local _checked_port=${1-""}
  local _container_name=${2-""}

  if [[ -z ${_checked_port} ]]; then
    show_error_message "Unable to check port allocation. Port number argument cannot be empty"
    exit 1
  fi

  local _containers_port=''
  if [[ -z "${_container_name}" ]]; then
    if [[ ! -z "$(docker ps -aq)" ]]; then
      _containers_port=$(docker inspect --format='{{json .HostConfig.PortBindings}}' $(docker ps -aq) | jq -r '.[]?[0].HostPort | values' | grep -E "^${_checked_port}$" | sort -g -r | head -n 1)
    fi
  else
    _containers_port=$(docker inspect --format='{{json .HostConfig.PortBindings}}' "${_container_name}" | jq -r '.[]?[0].HostPort | values' | grep -E "^${_checked_port}$" | sort -g -r | head -n 1)
  fi

  echo "${_containers_port}"
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

  _port_mask=$(get_port_full_search_mask ${_port_mask})
  if [[ "${os_type}" == "macos" ]]; then
    _port=$(sudo netstat -anvp tcp | grep -E "${_port_mask}" | grep "LISTEN" | grep -v "::1:" | awk '{print $4}' | sed 's/.*\.//' | sort -g -r | head -n 1)
  elif [[ "${os_type}" == "linux" ]]; then
    _port=$(sudo netstat -tlpn | grep -E "${_port_mask}" | grep "LISTEN" | grep -v "::1:" | awk '{print $4}' | sed 's/.*://' | sort -g -r | head -n 1)
  fi

  echo ${_port}
}

function get_port_full_search_mask() {
  local _port_mask=${1-""}

  if [[ -z ${_port_mask} ]]; then
    show_error_message "Unable to find available port by empty mask."
    exit 1
  fi

  # if mask is only numbers - prepend possible hosts to clarify output
  if [[ ! "${_port_mask}" =~ ^: ]]; then
    if [[ "${os_type}" == "macos" ]]; then
      # MacOs specific, Linux: port separator = semicolon, MacOs: port separator = dot
      _port_mask="(\*\.${_port_mask}\s)|(::.${_port_mask}\s)|(0\.0\.0\.0.${_port_mask}\s)|(127\.0\.0\.1.${_port_mask}\s)"
    elif [[ "${os_type}" == "linux" ]]; then
      # Linux: port separator = semicolon, MacOs: port separator = dot
      _port_mask="(\*\:${_port_mask}\s)|(:::${_port_mask}\s)|(0\.0\.0\.0:${_port_mask}\s)|(127\.0\.0\.1:${_port_mask}\s)"
    fi
  fi

  echo ${_port_mask}
}

############################ Local functions end ############################
