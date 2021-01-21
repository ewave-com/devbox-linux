#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/output.sh"
require_once "${devbox_root}/tools/system/file-copier.sh"

############################ Public functions ############################

nginx_reverse_proxy_restart() {
  sudo docker restart nginx-reverse-proxy > /dev/null
}

nginx_reverse_proxy_add_website() {
  local _website_config_path=${1-""}
  local _crt_file_name=${2-""}
  local _key_file_name=${3-""}

  nginx_reverse_proxy_prepare_common_folders

  nginx_reverse_proxy_add_website_config "${_website_config_path}"

  if [[ -n "${_crt_file_name}" ]]; then
    nginx_reverse_proxy_add_website_ssl_cert "${_crt_file_name}" "${_key_file_name}"
  fi
}

nginx_reverse_proxy_remove_project_website() {
  local _website_host_name=${1-""}
  local _crt_file_name=${2-""}

  if [[ -z "${_website_host_name}" ]]; then
    show_error_message "Unable to remove nginx revers-proxy website. Website host name cannot be empty."
    exit 1
  fi

  nginx_reverse_proxy_prepare_common_folders

  nginx_reverse_proxy_remove_website_config "${_website_host_name}.conf"
  nginx_reverse_proxy_remove_website_logs "${_website_host_name}"
  if [[ -n "${_crt_file_name}" ]]; then
    nginx_reverse_proxy_remove_website_ssl_cert "${_crt_file_name}"
  fi
}

############################ Public functions end ############################

############################ Local functions ############################

nginx_reverse_proxy_prepare_common_folders() {
  mkdir -p "${devbox_infra_dir}/nginx-reversproxy"
  sudo chown -R "${host_user}":"${host_user_group}" "${devbox_infra_dir}/nginx-reversproxy"

  mkdir -p "${devbox_infra_dir}/nginx-reversproxy/run/conf.d/"
  mkdir -p "${devbox_infra_dir}/nginx-reversproxy/run/logs/"
  mkdir -p "${devbox_infra_dir}/nginx-reversproxy/run/ssl/"
}

nginx_reverse_proxy_add_website_config() {
  local _website_config_path=$1

  if [[ -z "${_website_config_path}" ]]; then
    show_error_message "Unable to add nginx revers-proxy website. Source path of website config cannot be empty."
    exit 1
  fi

  copy_path "${_website_config_path}" "${devbox_infra_dir}/nginx-reversproxy/run/conf.d/"

  return 0
}

nginx_reverse_proxy_remove_website_config() {
  local _website_config_name=$1

  if [[ -z "${_website_config_name}" ]]; then
    show_error_message "Unable to remove nginx revers-proxy website config. Source path of website config cannot be empty."
    exit 1
  fi

  if [[ -f "${devbox_infra_dir}/nginx-reversproxy/run/conf.d/${_website_config_name}" ]]; then
    rm -rf "${devbox_infra_dir}/nginx-reversproxy/run/conf.d/${_website_config_name}"
  fi

  if [[ -f "${devbox_infra_dir}/nginx-reversproxy/run/conf.d/${_website_config_name}.conf" ]]; then
    rm -rf "${devbox_infra_dir}/nginx-reversproxy/run/conf.d/${_website_config_name}.conf"
  fi

  return 0
}

nginx_reverse_proxy_add_website_ssl_cert() {
  local _source_crt_path=$1
  local _source_key_path=${2-""}

  if [[ -z "${_source_crt_path}" ]]; then
    show_error_message "Unable to add nginx revers-proxy SSL certificate. Source path of certificate cannot be empty."
    exit 1
  fi

  copy_path "${_source_crt_path}" "${devbox_infra_dir}/nginx-reversproxy/run/ssl/"

  if [[ -z "${_source_key_path}" ]]; then
    _source_key_path="$(dirname ${_source_crt_path})/$(basename ${_source_crt_path} '.crt' ).key"
  fi

  if [[ -f "${_source_key_path}" ]]; then
    copy_path "${_source_key_path}" "${devbox_infra_dir}/nginx-reversproxy/run/ssl/"
  fi
}

nginx_reverse_proxy_remove_website_ssl_cert() {
  local _crt_file_name=$1
  local _key_file_name=${2-""}

  if [[ -z "${_crt_file_name}" ]]; then
    show_error_message "Unable to remove nginx revers-proxy SSL certificate. File name cannot be empty."
    exit 1
  fi

  if [[ -f "${devbox_infra_dir}/nginx-reversproxy/run/ssl/${_crt_file_name}" ]]; then
    rm -rf "${devbox_infra_dir}/nginx-reversproxy/run/ssl/${_crt_file_name}"
  fi

  if [[ -z "${_key_file_name}" ]]; then
    _key_file_name="${_crt_file_name%.*}.key"
  fi

  if [[ -f "${devbox_infra_dir}/nginx-reversproxy/run/ssl/${_key_file_name}" ]]; then
    rm -rf "${devbox_infra_dir}/nginx-reversproxy/run/ssl/${_key_file_name}"
  fi
}

nginx_reverse_proxy_remove_website_logs() {
  local _website_host_name=$1

  if [[ -z "${_website_host_name}" ]]; then
    show_error_message "Unable to remove nginx revers-proxy website logs. Website host name cannot be empty."
    exit 1
  fi

  rm -rf "${devbox_infra_dir}/nginx-reversproxy/run/logs/*${_website_host_name}.log" >/dev/null # 2>&1

  return 0
}

############################ Local functions end ############################
