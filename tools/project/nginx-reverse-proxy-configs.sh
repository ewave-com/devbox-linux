#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/file.sh"
require_once "${devbox_root}/tools/project/project-dotenv.sh"
require_once "${devbox_root}/tools/docker/nginx-reverse-proxy.sh"
require_once "${devbox_root}/tools/system/ssl.sh"
require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

function prepare_project_nginx_reverse_proxy_configs() {
  if [[ "${WEBSITE_PROTOCOL}" != "http" && "${WEBSITE_PROTOCOL}" != "https" ]]; then
    show_error_message "Website protocol must be either http or https. Please check WEBSITE_PROTOCOL in you .env file."
    exit 1
  fi

  local _nginx_proxy_config_filepath
  _nginx_proxy_config_filepath="${project_up_dir}/nginx-reverse-proxy/conf.d/${WEBSITE_HOST_NAME}.conf"
  # prepare http.conf.pattern or https.conf.pattern within docker-up directory
  copy_path_with_project_fallback "configs/nginx-reverse-proxy/${CONFIGS_PROVIDER_NGINX_PROXY}/conf.d/${WEBSITE_PROTOCOL}.conf.pattern" "${_nginx_proxy_config_filepath}"

  local _proxy_pass_container_name
  [[ "${VARNISH_ENABLE}" == "yes" ]] && _proxy_pass_container_name="${CONTAINER_VARNISH_NAME}" || _proxy_pass_container_name="${CONTAINER_WEB_NAME}"
  replace_value_in_file "${project_up_dir}/nginx-reverse-proxy/conf.d/${WEBSITE_HOST_NAME}.conf" "{{web_container_name}}" "${_proxy_pass_container_name}"

  local _website_nginx_extra_host_names=''
  if [[ -n "${WEBSITE_EXTRA_HOST_NAMES}" ]]; then
    _website_nginx_extra_host_names=$(echo "${WEBSITE_EXTRA_HOST_NAMES}" | tr ',' ' ')
  fi
  replace_value_in_file "${_nginx_proxy_config_filepath}" "{{website_extra_host_names_nginx_list}}" "${_website_nginx_extra_host_names}"

  replace_file_patterns_with_dotenv_params "${_nginx_proxy_config_filepath}"

  # Create ssl directory as it is common synced docker volume
  mkdir -p "${project_up_dir}/configs/ssl/"

  if [[ "${WEBSITE_PROTOCOL}" == 'http' ]]; then
    nginx_reverse_proxy_add_website "${_nginx_proxy_config_filepath}"
    return 0
  fi

  if [[ "${WEBSITE_PROTOCOL}" == 'https' ]]; then
    # find or generate certificate in ${project_up_dir}/configs/ssl
    prepare_website_ssl_certificate
    ssl_import_new_system_certificate "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.crt"

    nginx_reverse_proxy_add_website "${_nginx_proxy_config_filepath}" "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.crt"
  fi
}

function cleanup_project_nginx_reverse_proxy_configs() {
  if [[ "${WEBSITE_PROTOCOL}" == 'http' ]]; then
    nginx_reverse_proxy_remove_project_website "${WEBSITE_HOST_NAME}"
    return 0
  fi

  if [[ "${WEBSITE_PROTOCOL}" == 'https' ]]; then
    nginx_reverse_proxy_remove_project_website "${WEBSITE_HOST_NAME}" "${WEBSITE_SSL_CERT_FILENAME}.crt"
    ssl_disable_system_certificate "${WEBSITE_SSL_CERT_FILENAME}.crt"
  fi

}

############################ Public functions end ############################

############################ Local functions ############################

function prepare_website_ssl_certificate() {
  copy_path_with_project_fallback "configs/ssl/${CONFIGS_PROVIDER_SSL}/${WEBSITE_SSL_CERT_FILENAME}.crt" "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.crt" "0"
  copy_path_with_project_fallback "configs/ssl/${CONFIGS_PROVIDER_SSL}/${WEBSITE_SSL_CERT_FILENAME}.key" "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.key" "0"
  if [[ ! -f "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.crt" ]]; then
    ssl_generate_domain_certificate "${WEBSITE_HOST_NAME}" "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.crt"
  fi

  if [[ ! -f "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.crt" ]]; then
    show_error_message "Unable to apply HTTPS. Certificate is missing."
    show_error_message "Please ensure certificate files exist in common and project configs at path 'configs/ssl/${CONFIGS_PROVIDER_SSL}/${WEBSITE_SSL_CERT_FILENAME}.crt'"
    exit 1
  fi
}

############################ Local functions end ############################
