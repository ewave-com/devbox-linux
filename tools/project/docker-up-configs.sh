#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/config-replacer.sh"
require_once "${devbox_root}/tools/system/file.sh"
require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/project/project-dotenv.sh"
require_once "${devbox_root}/tools/project/project-state.sh"

############################ Public functions ############################

function prepare_project_docker_up_configs() {
  mkdir -p "${project_up_dir}"
  sudo chmod -R 777 "${project_up_dir}"

  prepare_website_configs

  if [[ ${MYSQL_ENABLE} == yes ]]; then
    prepare_mysql_configs
  fi

  if [[ ${VARNISH_ENABLE} == yes ]]; then
    prepare_varnish_configs
  fi

  if [[ ${ELASTICSEARCH_ENABLE} == yes ]]; then
    prepare_elasticsearch_configs
  fi

  if [[ ${REDIS_ENABLE} == yes ]]; then
    prepare_redis_configs
  fi

  if [[ ${BLACKFIRE_ENABLE} == yes ]]; then
    prepare_blackfire_configs
  fi

  if [[ ${POSTGRES_ENABLE} == yes ]]; then
    prepare_postgres_configs
  fi

  if [[ ${MONGODB_ENABLE} == yes ]]; then
    prepare_mongodb_configs
  fi

  if [[ ${RABBITMQ_ENABLE} == yes ]]; then
    prepare_rabbitmq_configs
  fi

  if [[ -n ${CUSTOM_COMPOSE} ]]; then
    prepare_custom_configs
  fi
}

function cleanup_project_docker_up_configs() {
  sudo chmod -R 777 "${project_up_dir}"

  # this wildcard doesn't with rm command
  # rm -rf "${project_up_dir}/docker-compose-.*.yml"
  for project_compose_file in $(ls "${project_up_dir}" | grep "docker-compose-.*.yml" | awk '{ print $1 }'); do
    rm -rf "${project_up_dir}/${project_compose_file}"
  done

  for project_sync_file in $(ls "${project_up_dir}" | grep "docker-sync-.*.yml" | awk '{ print $1 }'); do
    rm -rf "${project_up_dir}/${project_sync_file}"
  done

  rm -rf "${project_up_dir}/configs/"

  rm -rf "${project_up_dir}/docker-sync/"

  rm -rf "${project_up_dir}/nginx-reverse-proxy/"

  remove_state_file
}

############################ Public functions end ############################

############################ Local functions ############################

function prepare_website_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-website.yml" "${project_up_dir}/docker-compose-website.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-website.yml" "${project_up_dir}/.env"

  if [[ -n "${CONFIGS_PROVIDER_WEBSITE_DOCKER_SYNC}" ]]; then
    copy_path_with_project_fallback "configs/docker-sync/website/${CONFIGS_PROVIDER_WEBSITE_DOCKER_SYNC}/docker-sync-website.yml" "${project_up_dir}/docker-sync-website.yml"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-sync-website.yml" "${project_up_dir}/.env"
  fi

  # prepare composer cache sync or remove volume references if not required
  if [[ -n "${CONFIGS_PROVIDER_COMPOSER_CACHE_DOCKER_SYNC}" ]]; then
    copy_path_with_project_fallback "configs/docker-sync/composer/${CONFIGS_PROVIDER_COMPOSER_CACHE_DOCKER_SYNC}/docker-sync-composer.yml" "${project_up_dir}/docker-sync-composer.yml"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-sync-composer.yml" "${project_up_dir}/.env"
  else
    # remove sync mentioning from website volumes list
    _sync_name="${PROJECT_NAME}_${CONTAINER_WEB_NAME}_composer_cache_sync"
    if [[ "${os_type}" == "macos" ]]; then
      sed -i '' "/${_sync_name}\:\/var\/www\/\.composer/d" "${project_up_dir}/docker-compose-website.yml" # remove volume reference
      sed -i '' "/${_sync_name}:/{N;d;}" "${project_up_dir}/docker-compose-website.yml"                   # remove external volume mentioning
    elif [[ "${os_type}" == "linux" ]]; then
      sed -i "/${_sync_name}\:\/var\/www\/\.composer/d" "${project_up_dir}/docker-compose-website.yml"    # remove volume reference
      sed -i "/${_sync_name}:/{N;d;}" "${project_up_dir}/docker-compose-website.yml"                      # remove external volume mentioning
    fi
  fi

  # prepare node_modules sync or remove volume references if not required
  if [[ -n "${CONFIGS_PROVIDER_NODE_MODULES_DOCKER_SYNC}" ]]; then
    copy_path_with_project_fallback "configs/docker-sync/node_modules/${CONFIGS_PROVIDER_NODE_MODULES_DOCKER_SYNC}/docker-sync-node_modules.yml" "${project_up_dir}/docker-sync-node_modules.yml"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-sync-node_modules.yml" "${project_up_dir}/.env"
  else
    # remove sync mentioning from website volumes list
    _sync_name="${PROJECT_NAME}_${CONTAINER_WEB_NAME}_node_modules_sync"
    if [[ "${os_type}" == "macos" ]]; then
      sed -i '' "/${_sync_name}\:\/var\/www\/node_modules_remote/d" "${project_up_dir}/docker-compose-website.yml" # remove volume reference
      sed -i '' "/${_sync_name}:/{N;d;}" "${project_up_dir}/docker-compose-website.yml"                             # remove external volume mentioning
    elif [[ "${os_type}" == "linux" ]]; then
      sed -i "/${_sync_name}\:\/var\/www\/node_modules_remote/d" "${project_up_dir}/docker-compose-website.yml"    # remove volume reference
      sed -i "/${_sync_name}:/{N;d;}" "${project_up_dir}/docker-compose-website.yml"                                # remove external volume mentioning
    fi
  fi

  prepare_website_nginx_configs
  prepare_website_php_configs
  prepare_website_bash_configs

  mkdir -p "${project_up_dir}/configs/cron/"
}

# This function use in add_domain function
function prepare_website_nginx_configs() {
  mkdir -p "${project_up_dir}/configs/nginx/conf.d/"
  mkdir -p "${project_up_dir}/configs/nginx/logs/"

  local _config_target_filepath
  _config_target_filepath="${project_up_dir}/configs/nginx/conf.d/${WEBSITE_HOST_NAME}.conf"

  copy_path_with_project_fallback "configs/nginx/${CONFIGS_PROVIDER_NGINX}/conf/website.conf.pattern" "${_config_target_filepath}"

  local _website_nginx_extra_host_names=''
  if [[ -n "${WEBSITE_EXTRA_HOST_NAMES}" ]]; then
    _website_nginx_extra_host_names=$(echo "${WEBSITE_EXTRA_HOST_NAMES}" | tr ',' ' ')
  fi
  replace_value_in_file "${_config_target_filepath}" "{{website_extra_host_names_nginx_list}}" "${_website_nginx_extra_host_names}"

  # todo deprecated section, will be removed later, now vars are passed using function replace_file_patterns_with_dotenv_params
  replace_value_in_file "${_config_target_filepath}" "{{host_name}}" "${WEBSITE_HOST_NAME}"
  replace_value_in_file "${_config_target_filepath}" "{{document_root}}" "${WEBSITE_APPLICATION_ROOT}"
  # todo deprecated section end

  replace_file_patterns_with_dotenv_params "${_config_target_filepath}" "${project_up_dir}/.env"
}

function prepare_website_php_configs() {
  mkdir -p "${project_up_dir}/configs/php/"

  if [[ -n "${CONFIGS_PROVIDER_PHP}" ]]; then
    # processed files by default: php/ini/xdebug.ini.pattern, php/ini/zzz-custom.ini
    copy_path_with_project_fallback "configs/php/${CONFIGS_PROVIDER_PHP}/" "${project_up_dir}/configs/php/"

    # todo deprecated section, will be removed later, now vars are passed using function replace_file_patterns_with_dotenv_params
    if [[ -f "${project_up_dir}/configs/php/ini/xdebug.ini.pattern" ]]; then
      replace_value_in_file "${project_up_dir}/configs/php/ini/xdebug.ini.pattern" "{{server_ip}}" "${WEBSITE_PHP_XDEBUG_HOST}"
    fi
    if [[ -f "${project_up_dir}/configs/php/ini/xdebug.ini" ]]; then
      replace_value_in_file "${project_up_dir}/configs/php/ini/xdebug.ini" "{{server_ip}}" "${WEBSITE_PHP_XDEBUG_HOST}"
    fi
    # todo deprecated section end

    [[ -f "${project_up_dir}/configs/php/auto_prepend_file.php" ]] && _prepend_path="/etc/php/${PHP_VERSION}/auto_prepend_file.php" || _prepend_path=""
    if [[ -f "${project_up_dir}/configs/php/ini/zzz-custom.ini.pattern" ]]; then
      replace_value_in_file "${project_up_dir}/configs/php/ini/zzz-custom.ini.pattern" "{{auto_prepend_filepath}}" "${_prepend_path}"
    fi

    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/php/" "${project_up_dir}/.env"
  fi
}

function prepare_website_bash_configs() {
  mkdir -p "${project_up_dir}/configs/bash/"

  if [[ ! -f "${project_up_dir}/bash_history_web" ]]; then
    touch "${project_up_dir}/bash_history_web"
  fi

  if [[ -n "${CONFIGS_PROVIDER_BASH}" ]]; then
    copy_path_with_project_fallback "configs/bash/${CONFIGS_PROVIDER_BASH}/bashrc_www-data" "${project_up_dir}/configs/bash/bashrc_www-data"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/configs/bash/bashrc_www-data" "${project_up_dir}/.env"

    copy_path_with_project_fallback "configs/bash/${CONFIGS_PROVIDER_BASH}/bashrc_root" "${project_up_dir}/configs/bash/bashrc_root"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/configs/bash/bashrc_root" "${project_up_dir}/.env"
  fi
}

function prepare_mysql_configs() {
  mkdir -p "${project_up_dir}/configs/mysql/conf.d/"

  copy_path_with_project_fallback "configs/docker-compose/docker-compose-mysql.yml" "${project_up_dir}/docker-compose-mysql.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-mysql.yml" "${project_up_dir}/.env"

  if [[ -n "${CONFIGS_PROVIDER_MYSQL_DOCKER_SYNC}" ]]; then
    copy_path_with_project_fallback "configs/docker-sync/mysql/${CONFIGS_PROVIDER_MYSQL_DOCKER_SYNC}/docker-sync-mysql.yml" "${project_up_dir}/docker-sync-mysql.yml"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-sync-mysql.yml" "${project_up_dir}/.env"
  fi

  if [[ -n "${CONFIGS_PROVIDER_MYSQL}" ]]; then
    copy_path_with_project_fallback "configs/mysql/${CONFIGS_PROVIDER_MYSQL}/conf.d/custom.cnf" "${project_up_dir}/configs/mysql/conf.d/custom.cnf"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/configs/mysql/conf.d/custom.cnf" "${project_up_dir}/.env"
  fi
}

function prepare_varnish_configs() {
  mkdir -p "${project_up_dir}/configs/varnish/"

  copy_path_with_project_fallback "configs/docker-compose/docker-compose-varnish.yml" "${project_up_dir}/docker-compose-varnish.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-varnish.yml" "${project_up_dir}/.env"

  if [[ -n "${CONFIGS_PROVIDER_VARNISH}" ]]; then
    copy_path_with_project_fallback "configs/varnish/${CONFIGS_PROVIDER_VARNISH}/default.vcl.pattern" "${project_up_dir}/configs/varnish/default.vcl"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/configs/varnish/default.vcl" "${project_up_dir}/.env"
  fi
}

function prepare_elasticsearch_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-elasticsearch.yml" "${project_up_dir}/docker-compose-elasticsearch.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-elasticsearch.yml" "${project_up_dir}/.env"

  if [[ -n "${CONFIGS_PROVIDER_ELASTICSEARCH_DOCKER_SYNC}" ]]; then
    copy_path_with_project_fallback "configs/docker-sync/elasticsearch/${CONFIGS_PROVIDER_ELASTICSEARCH_DOCKER_SYNC}/docker-sync-elasticsearch.yml" "${project_up_dir}/docker-sync-elasticsearch.yml"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-sync-elasticsearch.yml" "${project_up_dir}/.env"
  fi

  if [[ -n "${CONFIGS_PROVIDER_ELASTICSEARCH}" ]]; then
    copy_path_with_project_fallback "configs/elasticsearch/${CONFIGS_PROVIDER_ELASTICSEARCH}/" "${project_up_dir}/configs/elasticsearch/" "0"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/elasticsearch/" "${project_up_dir}/.env"
  fi
}

function prepare_redis_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-redis.yml" "${project_up_dir}/docker-compose-redis.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-redis.yml" "${project_up_dir}/.env"

  if [[ -n "${CONFIGS_PROVIDER_REDIS}" ]]; then
    copy_path_with_project_fallback "configs/redis/${CONFIGS_PROVIDER_REDIS}/" "${project_up_dir}/configs/redis/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/redis/" "${project_up_dir}/.env"
  fi
}

function prepare_blackfire_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-blackfire.yml" "${project_up_dir}/docker-compose-blackfire.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-blackfire.yml" "${project_up_dir}/.env"

  if [[ -n "${CONFIGS_PROVIDER_BLACKFIRE}" ]]; then
    copy_path_with_project_fallback "configs/blackfire/${CONFIGS_PROVIDER_BLACKFIRE}/" "${project_up_dir}/configs/blackfire/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/blackfire/" "${project_up_dir}/.env"
  fi
}

function prepare_postgres_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-postgres.yml" "${project_up_dir}/docker-compose-postgres.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-postgres.yml" "${project_up_dir}/.env"

  if [[ -n "${CONFIGS_PROVIDER_POSTGRES}" ]]; then
    copy_path_with_project_fallback "configs/postgres/${CONFIGS_PROVIDER_POSTGRES}/" "${project_up_dir}/configs/postgres/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/postgres/" "${project_up_dir}/.env"
  fi
}

function prepare_mongodb_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-mongodb.yml" "${project_up_dir}/docker-compose-mongodb.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-mongodb.yml" "${project_up_dir}/.env"

  if [[ -n "${CONFIGS_PROVIDER_MONGODB}" ]]; then
    copy_path_with_project_fallback "configs/mongodb/${CONFIGS_PROVIDER_MONGODB}/" "${project_up_dir}/configs/mongodb/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/mongodb/" "${project_up_dir}/.env"
  fi
}

function prepare_rabbitmq_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-rabbitmq.yml" "${project_up_dir}/docker-compose-rabbitmq.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-rabbitmq.yml" "${project_up_dir}/.env"

  if [[ -n "${CONFIGS_PROVIDER_RABBITMQ}" ]]; then
    copy_path_with_project_fallback "configs/rabbitmq/${CONFIGS_PROVIDER_RABBITMQ}/" "${project_up_dir}/configs/rabbitmq/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/rabbitmq/" "${project_up_dir}/.env"
  fi
}

function prepare_custom_configs() {
  copy_path_with_project_fallback "configs/docker-compose/${CUSTOM_COMPOSE}" "${project_up_dir}/${CUSTOM_COMPOSE}"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/${CUSTOM_COMPOSE}" "${project_up_dir}/.env"

  if [[ -n "${CONFIGS_PROVIDER_CUSTOM}" ]]; then
    copy_path_with_project_fallback "configs/custom/${CONFIGS_PROVIDER_CUSTOM}/*" "${project_up_dir}/configs/custom/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/custom/" "${project_up_dir}/.env"
  fi
}

############################ Local functions end ############################
