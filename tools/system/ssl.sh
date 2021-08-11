#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

function ssl_import_new_system_certificate() {
  local _cert_source_path=$1

  add_system_ssl_certificate "${_cert_source_path}"
}

function ssl_disable_system_certificate() {
  local _cert_source_path=$1

  ssl_remove_system_certificate "${_cert_source_path}"
}

function ssl_generate_domain_certificate() {
  local _website_name=${1-''}
  local _target_crt_path=${2-''}
  local _target_key_path=${3-''}

  if [[ -z "${_website_name}" ]]; then
    show_error_message "Unable to generate CA certificate. Website name cannot be empty."
    exit 1
  fi

  if [[ -z "${_target_crt_path}" ]]; then
    show_error_message "Unable to generate CA certificate. Target path of certificate cannot be empty."
    exit 1
  fi

  if [[ -z "${_target_key_path}" ]]; then
    _target_key_path="$(dirname ${_target_crt_path})/$(basename ${_target_crt_path} '.crt').key"
  fi

  mkdir -p "$(dirname ${_target_crt_path})"

  openssl req -x509 -nodes \
    -newkey ec:<(openssl ecparam -name secp384r1) \
    -keyout ${_target_key_path} \
    -out ${_target_crt_path} \
    -days 365 \
    -subj '/C=BY/ST=Minsk/L=Minsk/O=DevOpsTeam_EWave/CN=${_website_name}' \
    >/dev/null

  if [[ "$?" != "0" ]]; then
    show_error_message "Unable to generate CA certificate. An error occurred during generation. See command output above."
    exit 1
  fi
}

############################ Public functions end ############################

############################ Local functions ############################

function add_system_ssl_certificate() {
  local _cert_source_path=$1

  if [[ -z "${_cert_source_path}" ]]; then
    show_error_message "Unable to add CA certificate. Filename cannot be empty."
    exit 1
  fi

  if [[ ! -f "${_cert_source_path}" ]]; then
    show_error_message "Unable to add CA certificate. Cert file does not exist at path '${_cert_source_path}'."
    exit 1
  fi

  if [[ "${os_type}" == "macos" ]]; then
    #how to: https://blog.sleeplessbeastie.eu/2016/11/28/how-to-import-self-signed-certificate-to-macos-system-keychain/
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "${_cert_source_path}"
  elif [[ "${os_type}" == "linux" ]]; then
    sudo cp -r "${_cert_source_path}" "/usr/local/share/ca-certificates/"
    sudo update-ca-certificates --fresh >/dev/null
  fi
}

function ssl_remove_system_certificate() {
  local _file_name=$1

  if [[ -z ${_file_name} ]]; then
    show_error_message "Unable to remove CA certificate. Filename cannot be empty."
    exit 1
  fi

  if [[ "${os_type}" == "macos" ]]; then
    #how to: https://unix.stackexchange.com/questions/227009/osx-delete-all-matching-certificates-by-command-line
    security find-certificate -c "${_file_name}" -a -Z | sudo awk '/SHA-1/{system("security delete-certificate -Z "$NF)}' >/dev/null
  elif [[ "${os_type}" == "linux" ]]; then
    sudo rm -rf "/usr/local/share/ca-certificates/${_file_name}" >/dev/null
    sudo update-ca-certificates --fresh >/dev/null
  fi
}

############################ Local functions end ############################
