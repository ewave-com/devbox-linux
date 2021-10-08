#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/file.sh"
require_once "${devbox_root}/tools/project/project-dotenv.sh"
require_once "${devbox_root}/tools/devbox/nginx-reverse-proxy.sh"
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

    nginx_reverse_proxy_add_website "${_nginx_proxy_config_filepath}" "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.crt"
  fi
}

function cleanup_project_nginx_reverse_proxy_configs() {
  local _full_clean=${1-'0'}

  if [[ "${WEBSITE_PROTOCOL}" == 'http' ]]; then
    nginx_reverse_proxy_remove_project_website "${WEBSITE_HOST_NAME}"
    return 0
  fi

  if [[ "${WEBSITE_PROTOCOL}" == 'https' ]]; then
    if [[ "${_full_clean}" == "1" ]]; then
      nginx_reverse_proxy_remove_project_website "${WEBSITE_HOST_NAME}" "${WEBSITE_SSL_CERT_FILENAME}.crt"
      ssl_disable_system_certificate "${WEBSITE_SSL_CERT_FILENAME}.crt"
    else
      nginx_reverse_proxy_remove_project_website "${WEBSITE_HOST_NAME}"
    fi
  fi
}

############################ Public functions end ############################

############################ Local functions ############################

function prepare_website_ssl_certificate() {
  copy_path_with_project_fallback "configs/ssl/${CONFIGS_PROVIDER_SSL}/${WEBSITE_SSL_CERT_FILENAME}.crt" "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.crt" "0"
  copy_path_with_project_fallback "configs/ssl/${CONFIGS_PROVIDER_SSL}/${WEBSITE_SSL_CERT_FILENAME}.key" "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.key" "0"
  if [[ ! -f "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.crt" ]]; then
    local _extra_domains
    [[ -z "${WEBSITE_EXTRA_HOST_NAMES+x}" ]] && _extra_domains="" || _extra_domains="${WEBSITE_EXTRA_HOST_NAMES}"

    _ssl_dir="${devbox_infra_dir}/nginx-reverse-proxy/run/ssl"
    if [[ ! -f "${_ssl_dir}/DevboxRootCA.crt" || ! -f "${_ssl_dir}/DevboxRootCA.pem" || ! -f "${_ssl_dir}/DevboxRootCA.key" ]]; then
      ssl_generate_root_certificate_authority "${_ssl_dir}/DevboxRootCA.crt"
      ssl_import_new_system_certificate "${_ssl_dir}/DevboxRootCA.crt"

      show_success_message "Devbox Root CA has been generated and imported to your system."
      show_warning_message "If you still see the warning about insecure connection in your browser please import the certificate authority to your browser. "
      show_warning_message "Root CA Path: ${_ssl_dir}/DevboxRootCA.crt"
    fi

    ssl_generate_domain_certificate "${WEBSITE_HOST_NAME}" "${_extra_domains}" "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.crt" "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.key" "${_ssl_dir}/DevboxRootCA.pem" "${_ssl_dir}/DevboxRootCA.key"
  fi

  if [[ ! -f "${project_up_dir}/configs/ssl/${WEBSITE_SSL_CERT_FILENAME}.crt" ]]; then
    show_error_message "Unable to apply HTTPS. Certificate is missing."
    show_error_message "Please ensure certificate files exist in common and project configs at path 'configs/ssl/${CONFIGS_PROVIDER_SSL}/${WEBSITE_SSL_CERT_FILENAME}.crt'"
    exit 1
  fi
}

############################ Local functions end ############################
