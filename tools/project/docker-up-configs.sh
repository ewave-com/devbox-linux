#!/usr/bin/env bash

require_once ${devbox_root}/tools/system/config-replacer.sh
require_once ${devbox_root}/tools/system/file-copier.sh
require_once ${devbox_root}/tools/system/output.sh
require_once ${devbox_root}/tools/project/dotenv.sh

############################ Public functions ############################

prepare_project_docker_up_configs() {
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

cleanup_project_docker_up_configs() {
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

  rm -rf "${project_up_dir}/nginx-reversproxy/"
}

############################ Public functions end ############################

############################ Local functions ############################

prepare_website_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-website.yml" "${project_up_dir}/docker-compose-website.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-website.yml"

  if [[ -n "${CONFIGS_PROVIDER_WEBSITE_DOCKER_SYNC}" ]]; then
    copy_path_with_project_fallback "configs/docker-sync/website/${CONFIGS_PROVIDER_WEBSITE_DOCKER_SYNC}/docker-sync-website.yml" "${project_up_dir}/docker-sync-website.yml"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-sync-website.yml"
  fi

  prepare_website_nginx_configs
  prepare_website_php_configs
  prepare_website_bash_configs

  mkdir -p "${project_up_dir}/configs/cron/"
}

# This function use in add_domain function
prepare_website_nginx_configs() {
  mkdir -p "${project_up_dir}/configs/nginx/conf.d/"
  mkdir -p "${project_up_dir}/configs/nginx/logs/"

  local _config_target_filepath
  _config_target_filepath="${project_up_dir}/configs/nginx/conf.d/${WEBSITE_HOST_NAME}.conf"

  copy_path_with_project_fallback "configs/nginx/${CONFIGS_PROVIDER_NGINX}/conf/website.conf.pattern" "${_config_target_filepath}"

  local _website_nginx_extra_host_names=''
  if [[ -n "${WEBSITE_EXTRA_HOST_NAMES}" ]]; then
    _website_nginx_extra_host_names=$(echo "${WEBSITE_EXTRA_HOST_NAMES}" | tr ',' ' ')
  fi
  replace_value_in_file "${_config_target_filepath}" "{{WEBSITE_EXTRA_HOST_NAMES_SS}}" "${_website_nginx_extra_host_names}"

  # todo deprecated section, will be removed later, now vars are passed using function replace_file_patterns_with_dotenv_params
  replace_value_in_file "${_config_target_filepath}" "{{host_name}}" "${WEBSITE_HOST_NAME}"
  replace_value_in_file "${_config_target_filepath}" "{{document_root}}" "${WEBSITE_APPLICATION_ROOT}"
  # todo deprecated section end

  replace_file_patterns_with_dotenv_params "${_config_target_filepath}"
}

prepare_website_php_configs() {
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

    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/php/"
  fi
}

prepare_website_bash_configs() {
  mkdir -p "${project_up_dir}/configs/bash/"

  if [[ ! -f "${project_up_dir}/bash_history_web" ]]; then
    touch "${project_up_dir}/bash_history_web"
  fi

  if [[ -n "${CONFIGS_PROVIDER_BASH}" ]]; then
    copy_path_with_project_fallback "configs/bash/${CONFIGS_PROVIDER_BASH}/bashrc_www-data" "${project_up_dir}/configs/bash/bashrc_www-data"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/configs/bash/bashrc_www-data"

    copy_path_with_project_fallback "configs/bash/${CONFIGS_PROVIDER_BASH}/bashrc_root" "${project_up_dir}/configs/bash/bashrc_root"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/configs/bash/bashrc_root"
  fi
}

prepare_mysql_configs() {
  mkdir -p "${project_up_dir}/configs/mysql/conf.d/"

  copy_path_with_project_fallback "configs/docker-compose/docker-compose-mysql.yml" "${project_up_dir}/docker-compose-mysql.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-mysql.yml"

  if [[ -n "${CONFIGS_PROVIDER_MYSQL_DOCKER_SYNC}" ]]; then
    copy_path_with_project_fallback "configs/docker-sync/mysql/${CONFIGS_PROVIDER_MYSQL_DOCKER_SYNC}/docker-sync-mysql.yml" "${project_up_dir}/docker-sync-mysql.yml"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-sync-mysql.yml"
  fi

  if [[ -n "${CONFIGS_PROVIDER_MYSQL}" ]]; then
    copy_path_with_project_fallback "configs/mysql/${CONFIGS_PROVIDER_MYSQL}/conf.d/custom.cnf" "${project_up_dir}/configs/mysql/conf.d/custom.cnf"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/configs/mysql/conf.d/custom.cnf"
  fi
}

prepare_varnish_configs() {
  mkdir -p "${project_up_dir}/configs/varnish/"

  copy_path_with_project_fallback "configs/docker-compose/docker-compose-varnish.yml" "${project_up_dir}/docker-compose-varnish.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-varnish.yml"

  if [[ -n "${CONFIGS_PROVIDER_VARNISH}" ]]; then
    copy_path_with_project_fallback "configs/varnish/${CONFIGS_PROVIDER_VARNISH}/default.vcl.pattern" "${project_up_dir}/configs/varnish/default.vcl"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/configs/varnish/default.vcl"
  fi
}

prepare_elasticsearch_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-elasticsearch.yml" "${project_up_dir}/docker-compose-elasticsearch.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-elasticsearch.yml"

  if [[ -n "${CONFIGS_PROVIDER_ELASTICSEARCH_DOCKER_SYNC}" ]]; then
    copy_path_with_project_fallback "configs/docker-sync/elasticsearch/${CONFIGS_PROVIDER_ELASTICSEARCH_DOCKER_SYNC}/docker-sync-elasticsearch.yml" "${project_up_dir}/docker-sync-elasticsearch.yml"
    replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-sync-elasticsearch.yml"
  fi

  if [[ -n "${CONFIGS_PROVIDER_ELASTICSEARCH}" ]]; then
    copy_path_with_project_fallback "configs/elasticsearch/${CONFIGS_PROVIDER_ELASTICSEARCH}/" "${project_up_dir}/configs/elasticsearch/" "0"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/elasticsearch/" "0"
  fi
}

prepare_redis_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-redis.yml" "${project_up_dir}/docker-compose-redis.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-redis.yml"

  if [[ -n "${CONFIGS_PROVIDER_REDIS}" ]]; then
    copy_path_with_project_fallback "configs/redis/${CONFIGS_PROVIDER_REDIS}/" "${project_up_dir}/configs/redis/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/redis/" "0"
  fi
}

prepare_blackfire_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-blackfire.yml" "${project_up_dir}/docker-compose-blackfire.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-blackfire.yml"

  if [[ -n "${CONFIGS_PROVIDER_BLACKFIRE}" ]]; then
    copy_path_with_project_fallback "configs/blackfire/${CONFIGS_PROVIDER_BLACKFIRE}/" "${project_up_dir}/configs/blackfire/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/blackfire/" "0"
  fi
}

prepare_postgres_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-postgres.yml" "${project_up_dir}/docker-compose-postgres.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-postgres.yml"

  if [[ -n "${CONFIGS_PROVIDER_POSTGRES}" ]]; then
    copy_path_with_project_fallback "configs/postgres/${CONFIGS_PROVIDER_POSTGRES}/" "${project_up_dir}/configs/postgres/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/postgres/" "0"
  fi
}

prepare_mongodb_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-mongodb.yml" "${project_up_dir}/docker-compose-mongodb.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-mongodb.yml"

  if [[ -n "${CONFIGS_PROVIDER_MONGODB}" ]]; then
    copy_path_with_project_fallback "configs/mongodb/${CONFIGS_PROVIDER_MONGODB}/" "${project_up_dir}/configs/mongodb/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/mongodb/" "0"
  fi
}

prepare_rabbitmq_configs() {
  copy_path_with_project_fallback "configs/docker-compose/docker-compose-rabbitmq.yml" "${project_up_dir}/docker-compose-rabbitmq.yml"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/docker-compose-rabbitmq.yml"

  if [[ -n "${CONFIGS_PROVIDER_RABBITMQ}" ]]; then
    copy_path_with_project_fallback "configs/rabbitmq/${CONFIGS_PROVIDER_RABBITMQ}/" "${project_up_dir}/configs/rabbitmq/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/rabbitmq/" "0"
  fi
}

prepare_custom_configs() {
  copy_path_with_project_fallback "configs/docker/${CUSTOM_COMPOSE}" "${project_up_dir}/${CUSTOM_COMPOSE}"
  replace_file_patterns_with_dotenv_params "${project_up_dir}/${CUSTOM_COMPOSE}"

  if [[ -n "${CONFIGS_PROVIDER_CUSTOM}" ]]; then
    copy_path_with_project_fallback "configs/custom/${CONFIGS_PROVIDER_CUSTOM}/*" "${project_up_dir}/configs/custom/"
    replace_directory_files_patterns_with_dotenv_params "${project_up_dir}/configs/custom/" "0"
  fi
}

############################ Local functions end ############################
