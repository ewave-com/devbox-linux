#!/usr/bin/env bash
# info: actions with env file

require_once ${devbox_root}/tools/system/constants.sh
require_once ${devbox_root}/tools/system/free-port.sh
require_once ${devbox_root}/tools/system/output.sh

############################ Public functions ############################

dotenv_prepare_project_variables() {
  local _force=${1-"0"}

  dotenv_prepare_project_file "${_force}"
  dotenv_export_variables
}

# Function which exports variable from ENV file
dotenv_export_variables() {
  export $(cat "${project_up_dir}/.env" | grep -Ev "^$" | grep -v '^#' | xargs)
}
# Function which unset variable from ENV file
# Run function ONLY in the END
dotenv_unset_variables() {
  unset $(cat "${project_up_dir}/.env" | grep -Ev "^$" | grep -v '^#' | sed -E 's/(.*)=.*/\1/' | xargs)
}

# check if param is presented in the given .env file
dotenv_has_param() {
  local _param_name=$1
  local _env_filepath=${2-"${project_up_dir}/.env"}

  dotenv_ensure_param_is_readable "${_param_name}" "${_env_filepath}"

  local _param_presented
  _param_presented=$(cat "${_env_filepath}" | grep "^${_param_name}=")
  if [[ -n ${_param_presented} ]]; then
    echo "1"
  else
    echo "0"
  fi
}

# check if param has not empty value in the given .env file
dotenv_has_param_value() {
  local _param_name=$1
  local _env_filepath=${2-"${project_up_dir}/.env"}

  dotenv_ensure_param_is_readable "${_param_name}" "${_env_filepath}"

  local _param_value_presented
  _param_value_presented=$(cat "${_env_filepath}" | grep "^${_param_name}=" | awk -F= '{print $2}')
  if [[ -n ${_param_value_presented} ]]; then
    echo "1"
  else
    echo "0"
  fi
}

# get value the given .env file by the param name
dotenv_get_param_value() {
  local _param_name=$1
  local _env_filepath=${2-"${project_up_dir}/.env"}

  dotenv_ensure_param_is_readable "${_param_name}" "${_env_filepath}"

  echo $(cat "${_env_filepath}" | grep "^${_param_name}=" | awk -F= '{print $2}')
}

# set value the given .env file by the param name
dotenv_set_param_value() {
  local _param_name=$1
  local _param_value=${2-""}
  local _env_filepath=${3-"${project_up_dir}/.env"}

  dotenv_ensure_param_is_readable "${_param_name}" "${_env_filepath}"

  local _param_presented
  _param_presented=$(dotenv_has_param "${_param_name}")
  if [[ "${_param_presented}" != "0" ]]; then
    if [[ "${os_type}" == "macos" ]]; then
      sed -i '' "s|^${_param_name}=.*|${_param_name}=${_param_value}|g" ${_env_filepath}
    elif [[ "${os_type}" == "linux" ]]; then
      sed -i "s|^${_param_name}=.*|${_param_name}=${_param_value}|g" ${_env_filepath}
    fi
  else
    echo -en "${_param_name}=${_param_value}\n" >>"${_env_filepath}"
  fi

  return 0
}

replace_file_patterns_with_dotenv_params() {
  local _filepath=$1

  if [[ -z ${_filepath} ]]; then
    show_error_message "Unable to replace config value at path \"${_filepath}\". Path can not be empty."
    exit 1
  fi

  if [[ ! -f ${_filepath} ]]; then
    show_error_message "Unable to replace patterns with env params at path \"${_filepath}\". Path does not exist!"
    exit 1
  fi

  local _pattern
  local _param_value
  local _unprocessed_pattern_found="0"
  for _pattern in $(cat "${_filepath}" | grep -oE "\{\{[A-Za-z0-9_-]*\}\}"); do
    local _param_name
    _param_name=$(echo "${_pattern}" | sed -E 's/[{}]//g')

    # read variable from exported shell variables if exists
    if [[ -z "${_param_name+x}" ]]; then
      _param_value="$(printenv ${_param_name})"
      replace_value_in_file "${_filepath}" "${_pattern}" "${_param_value}"
      continue
    fi

    local _param_presented
    _param_presented=$(dotenv_has_param "${_param_name}")
    # search for pattern variable in project .env file if presented
    if [[ "${_param_presented}" == "1" ]]; then
      _param_value=$(dotenv_get_param_value "${_param_name}")
      replace_value_in_file "${_filepath}" "${_pattern}" "${_param_value}"
      continue
    fi

    _unprocessed_pattern_found="1"
    show_warning_message " \"Unprocessed pattern \"${_pattern}\" found at path \""${_filepath}"\""
  done

  if [[ "${_unprocessed_pattern_found}" != "0" ]]; then
    show_error_message "Not all patterns were prepared at path \"${_filepath}\"."
    show_error_message "Ensure all required params are presented in project .env file or contact DevBox developers."
    exit 1
  fi
}

replace_directory_files_patterns_with_dotenv_params() {
  local _dir_path=${1-""}
  local _strict_mode=${1-"1"}

  if [[ -z "${_dir_path}" ]]; then
    show_error_message "Unable to replace directory files with dotenv variables. Directory path cannot be empty."
    exit 1
  fi

  if [[ ! -d "${_dir_path}" ]]; then
    if [[ "${_strict_mode}" == "1" ]]; then
      show_error_message "Unable to replace directory files with dotenv variables. Directory does not exist at path \"${_dir_path}\"."
      exit 1
    else
      return 0
    fi
  fi

  if [[ "${_dir_path: -1}" == "/" ]]; then
    _dir_path="$(echo ${_dir_path} | sed 's|/$||')"
  fi

  for _config_path in $(find "${_dir_path}" -type f); do
    # remove extension ".pattern" from the file path if presented
    if [[ "${_config_path: -8}" == ".pattern" ]]; then
      _new_config_path="$(echo ${_config_path} | sed 's|.pattern$||')"
      mv "${_config_path}" "${_new_config_path}"
      _config_path="${_new_config_path}"
    fi

    replace_file_patterns_with_dotenv_params ${_config_path}
  done

  return 0
}

############################ Public functions end ############################

############################ Local functions ############################

dotenv_prepare_project_file() {
  local _force=${1-"0"}

  if [[ ! -f "${project_dir}/.env" ]]; then
    show_error_message "File .ENV not found! Please put configuration file exists at path \"${project_dir}/.env\" and try again."
    exit 1
  fi

  if [[ -f "${project_up_dir}/.env" && "${_force}" == "0" ]]; then
    return 0
  fi

  mkdir -p "${project_up_dir}"
  cp -r "${project_dir}/.env" "${project_up_dir}/.env"

  dotenv_replace_line_endings "${project_up_dir}/.env"
  dotenv_apply_backward_compatibility_transformations "${project_up_dir}/.env"
  dotenv_merge_defaults "${project_up_dir}/.env"
  dotenv_add_computed_params "${project_up_dir}/.env"
  dotenv_add_static_dir_paths "${project_up_dir}/.env"
  dotenv_evaluate_expression_values "${project_up_dir}/.env"
}

#Prepare ENV file. Delete '\r' '\n' from file
dotenv_replace_line_endings() {
  local _env_filepath=${1-"${project_up_dir}/.env"}
  if [[ ! -f ${_env_filepath} ]]; then
    show_error_message "Unable to replace endings in the project file .env. Project .env file doesn't exist at path \"${_env_filepath}\"."
    exit 1
  fi

  sudo chmod -R 777 "${project_up_dir}/"
  tr '\r\n' '\n' <"${project_up_dir}/.env" >"${project_up_dir}/newfile.env"
  mv "${project_up_dir}/newfile.env" "${project_up_dir}/.env"
  #  sudo chmod -R 777 "${project_up_dir}/.env" && sudo chown -R www-data:www-data "${project_up_dir}/.env"
  #  sudo tr '\r' '\n' <"${project_up_dir}/.env" >"${project_up_dir}/newfile.env"
  #  sudo chmod -R 777 "${project_up_dir}/newfile.env" && sudo chown -R www-data:www-data "${project_up_dir}/newfile.env"
  #  mv "${project_up_dir}/newfile.env" "${project_up_dir}/.env"

  return 0
}

dotenv_merge_defaults() {
  local _env_filepath=${1-"${project_up_dir}/.env"}
  if [[ ! -f ${_env_filepath} ]]; then
    show_error_message "Unable to apply .env defaults. Project .env file doesn't exist at path \"${_env_filepath}\"."
    exit 1
  fi

  echo -en "\n\n" >>"${_env_filepath}"
  echo "########## Default params ##########" >>"${_env_filepath}"
  echo -en "# The following params added from defaults source file: \"${dotenv_defaults_filepath}\"\n" >>"${_env_filepath}"

  # | sed -e 's/.*=//g'
  for param_line in $(cat "${dotenv_defaults_filepath}" | grep -Ev "^$" | grep -v '^#'); do
    local _param_name
    _param_name=$(echo "${param_line}" | awk -F= '{print $1}')

    local _param_presented
    _param_presented=$(dotenv_has_param "${_param_name}")
    if [[ "${_param_presented}" == "0" ]]; then
      local _param_default_value
      _param_default_value=$(echo "${param_line}" | awk -F= '{print $2}')
      echo -en "${_param_name}=${_param_default_value}\n" >>"${_env_filepath}"
    fi
  done

  return 0
}

dotenv_apply_backward_compatibility_transformations() {
  local _env_filepath=${1-"${project_up_dir}/.env"}

  # append php version to image name for madebyewave image
  local _web_image
  _web_image=$(dotenv_get_param_value "CONTAINER_WEB_IMAGE")
  local _php_version
  _php_version=$(dotenv_get_param_value "PHP_VERSION")
  if [[ "${_web_image}" == "madebyewave/devbox-nginx-php" ]]; then
    dotenv_set_param_value CONTAINER_WEB_IMAGE "${_web_image}${_php_version}"
  fi

  # config params *ELASTIC* were renamed to *ELASTICSEARCH*, copy all params with new names
  if [[ "$(dotenv_has_param ELASTIC_ENABLE)" == "1" ]]; then
    dotenv_set_param_value ELASTICSEARCH_ENABLE "$(dotenv_get_param_value ELASTIC_ENABLE)"
    dotenv_set_param_value CONTAINER_ELASTICSEARCH_NAME "$(dotenv_get_param_value CONTAINER_ELASTIC_NAME)"
    dotenv_set_param_value CONTAINER_ELASTICSEARCH_IMAGE "$(dotenv_get_param_value CONTAINER_ELASTIC_IMAGE)"
    dotenv_set_param_value CONTAINER_ELASTICSEARCH_VERSION "$(dotenv_get_param_value CONTAINER_ELASTIC_VERSION)"
    dotenv_set_param_value CONFIGS_PROVIDER_ELASTICSEARCH "$(dotenv_get_param_value CONFIGS_PROVIDER_ELASTIC)"
  fi

  if [[ "$(dotenv_has_param CONFIGS_PROVIDER_UNISON)" == "1" && "$(dotenv_get_param_value CONFIGS_PROVIDER_WEBSITE_DOCKER_SYNC)" == "" ]]; then
    dotenv_set_param_value CONFIGS_PROVIDER_WEBSITE_DOCKER_SYNC "$(dotenv_get_param_value CONFIGS_PROVIDER_UNISON)"
  fi

  # db/ and es/ directories were moved into sysdumps/ dir in within project dir
  if [[ -d "${project_dir}/db/" && ! -d "${project_dir}/sysdumps/db/" ]]; then
    sudo mkdir -p "${project_dir}/sysdumps/db/"
    sudo mv "${project_dir}/db" "${project_dir}/sysdumps/db"
  fi

  if [[ -d "${project_dir}/es/" && ! -d "${project_dir}/sysdumps/es/" ]]; then
    sudo mkdir -p "${project_dir}/sysdumps/es/"
    sudo mv "${project_dir}/es" "${project_dir}/sysdumps/es"
  fi

  if [[ -d "${project_dir}/node_modules/" && ! -d "${project_dir}/sysdumps/node_modules/" ]]; then
    sudo mkdir -p "${project_dir}/sysdumps/node_modules/"
    sudo mv "${project_dir}/es" "${project_dir}/sysdumps/node_modules"
  fi
}

dotenv_add_computed_params() {
  # ensure mysql external port is available to be exposed or compute a free one
  local _mysql_enable
  _mysql_enable=$(dotenv_get_param_value "MYSQL_ENABLE")
  if [[ "${_mysql_enable}" == "yes" ]]; then
    local _configured_mysql_port
    _configured_mysql_port=$(dotenv_get_param_value "CONTAINER_MYSQL_PORT")
    if [[ -n ${_configured_mysql_port} ]]; then
      ensure_mysql_port_is_available ${_configured_mysql_port}
    else
      local _computed_mysql_port
      _computed_mysql_port=$(get_available_mysql_port)
      ensure_mysql_port_is_available ${_computed_mysql_port}
      dotenv_set_param_value "CONTAINER_MYSQL_PORT" ${_computed_mysql_port}
    fi
  fi

  # ensure elasticsearch external port is available to be exposed or compute a free one
  local _es_enable
  _es_enable=$(dotenv_get_param_value "ELASTICSEARCH_ENABLE")
  if [[ "${_es_enable}" == "yes" ]]; then
    local _configured_es_port
    _configured_es_port=$(dotenv_get_param_value "CONTAINER_ELASTICSEARCH_PORT")
    if [[ -n ${_configured_es_port} ]]; then
      ensure_elasticsearch_port_is_available ${_configured_es_port}
    else
      local _computed_es_port
      _computed_es_port=$(get_available_elasticsearch_port)
      ensure_elasticsearch_port_is_available ${_computed_es_port}
      dotenv_set_param_value "CONTAINER_ELASTICSEARCH_PORT" ${_computed_es_port}
    fi
  fi

  # ensure ssh external port is available to be exposed or compute a free one
  local _configured_ssh_port
  _configured_ssh_port=$(dotenv_get_param_value "CONTAINER_WEB_SSH_PORT")
  if [[ -n "${_configured_ssh_port}" ]]; then
    ensure_ssh_port_is_available "${_configured_ssh_port}"
  else
    local _computed_ssh_port
    _computed_ssh_port=$(get_available_ssh_port)
    ensure_ssh_port_is_available "${_computed_ssh_port}"
    dotenv_set_param_value "CONTAINER_WEB_SSH_PORT" "${_computed_ssh_port}"
  fi

  # ensure unison external port is available to be exposed or compute a free one
  # WinOs / MacOs specific
#  local _configured_unison_port
#  _configured_unison_port=$(dotenv_get_param_value "CONTAINER_WEB_UNISON_PORT")
#  if [[ -n "${_configured_unison_port}" ]]; then
#    ensure_unison_port_is_available "${_configured_unison_port}"
#  else
#    local _computed_unison_port
#    _computed_unison_port=$(get_available_unison_port)
#    ensure_unison_port_is_available "${_computed_unison_port}"
#    dotenv_set_param_value "CONTAINER_WEB_UNISON_PORT" "${_computed_unison_port}"
#  fi

  # fill WEBSITE_PHP_XDEBUG_HOST if empty
  local _configured_xdebug_host
  _configured_xdebug_host=$(dotenv_get_param_value "WEBSITE_PHP_XDEBUG_HOST")
  if [[ -z "${_configured_xdebug_host}" ]]; then
    local _computed_xdebug_host
    if [[ "${os_type}" == "macos" ]]; then
      local _computed_xdebug_host="host.docker.internal"
    elif [[ "${os_type}" == "linux" ]]; then
      _computed_xdebug_host=$(ip addr show docker0 | grep -Po 'inet \K[\d.]+')
      if [[ -z "${_computed_xdebug_host}" ]]; then
        _computed_xdebug_host='172.17.0.1' # common internal docker ip
      fi
    fi
    dotenv_set_param_value "WEBSITE_PHP_XDEBUG_HOST" "${_computed_xdebug_host}"
  fi

  return 0
}

dotenv_add_static_dir_paths() {
  local _env_filepath=${1-"${project_up_dir}/.env"}

  dotenv_set_param_value DEVBOX_PROJECT_DIR "${project_dir}"
  dotenv_set_param_value DEVBOX_PROJECT_UP_DIR "${project_up_dir}"
}

dotenv_evaluate_expression_values() {
  local _env_filepath=${1-"${project_up_dir}/.env"}
  # find all variables with $ which should be expanded
  for _param_line in $(cat "${_env_filepath}" | grep -Ev "^$" | grep -v '^#' | grep '\$'); do
    local _param_value=$(echo "${_param_line}" | awk -F'=' '{ print $2 }')
    local _evaluated_param_value="${_param_value}"
    # if value has patterns "${_some_word_}" it should be evaluated
    if [[ $(echo "${_param_value}" | grep -E '\$\{?[A-Za-z0-9_-]*\}?') ]]; then
      for _param_pattern in $(echo "${_param_value}" | grep -oE '\$\{?([A-Za-z0-9_-]*)\}?'); do
        _eval_param_name=$(echo "${_param_pattern}" | tr -d '${}')
        local _evaluated_value=$(dotenv_get_param_value "${_eval_param_name}")
        _evaluated_param_value=$(echo "${_evaluated_param_value}" | sed "s|${_param_pattern}|${_evaluated_value}|g")
      done
    fi

    if [[ "${_evaluated_param_value}" != "${_param_value}" ]]; then
      local _param_name=$(echo "${_param_line}" | awk -F'=' '{ print $1 }')
      dotenv_set_param_value "${_param_name}" "${_evaluated_param_value}"
    fi
  done
}

# check param name is presented and checked file exists
dotenv_ensure_param_is_readable() {
  local _param_name=$1
  local _env_filepath=${2-"${project_up_dir}/.env"}

  if [[ -z ${_param_name} ]]; then
    show_error_message "Unable to read .env value. Param name cannot be empty"
    exit 1
  fi

  if [[ ! -f ${_env_filepath} ]]; then
    show_error_message "Unable to read .env param. Project .env file doesn't exist at path \"${_env_filepath}\"."
    exit 1
  fi

  return 0
}

############################ Local functions end ############################
