#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

function ssl_add_system_certificate() {
  local _cert_source_path=$1
  local _subject_search_pattern=${2-''}
  local _is_root_ca=${3-'0'}

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
    if [[ "${_is_root_ca}" == "1" ]]; then
      _resultType="trustRoot"
    else
      _resultType="trustAsRoot"
    fi
    if [[ -z $(security find-certificate -c "${_subject_search_pattern}" -a "/Library/Keychains/System.keychain") ]]; then
      sudo security add-trusted-cert -d -r "${_resultType}" -k "/Library/Keychains/System.keychain" "${_cert_source_path}"
    fi
  elif [[ "${os_type}" == "linux" ]]; then
    if [[ ! -f "/usr/local/share/ca-certificates/$(basename ${_cert_source_path})" ]]; then
      sudo cp -r "${_cert_source_path}" "/usr/local/share/ca-certificates/"
      sudo update-ca-certificates --fresh >/dev/null
    fi
  fi
}

function ssl_delete_system_certificate() {
  local _cert_source_path=$1
  local _subject_search_pattern=${2-''}
  local _is_root_ca=${3-'0'}

  if [[ -z ${_cert_source_path} ]]; then
    show_error_message "Unable to remove CA certificate. Filename cannot be empty."
    exit 1
  fi

  if [[ "${os_type}" == "macos" ]]; then
    #how to: https://unix.stackexchange.com/questions/227009/osx-delete-all-matching-certificates-by-command-line
    if [[ ! -z $(security find-certificate -c "${_subject_search_pattern}" -a "/Library/Keychains/System.keychain") ]]; then
      security find-certificate -c "${_subject_search_pattern}" -a -Z "/Library/Keychains/System.keychain" | sudo awk '/SHA-1/{system("security delete-certificate -Z "$NF)}' >/dev/null
    fi
  elif [[ "${os_type}" == "linux" ]]; then
    if [[ -f "/usr/local/share/ca-certificates/${_cert_source_path}" ]]; then
      sudo rm -rf "/usr/local/share/ca-certificates/${_cert_source_path}" >/dev/null
      sudo update-ca-certificates --fresh >/dev/null
    fi
  fi
}

function ssl_generate_root_certificate_authority() {
  local _target_root_crt_path=${1-''}
  local _target_root_key_path=${2-''}

  if [[ -z "${_target_root_crt_path}" ]]; then
    show_error_message "Unable to generate Root CA certificate. Target path of certificate cannot be empty."
    exit 1
  fi

  local _cert_basename
  _cert_basename=$(basename ${_target_root_crt_path} '.crt')

  if [[ -z "${_target_root_key_path}" ]]; then
    _target_root_key_path="$(dirname ${_target_root_crt_path})/${_cert_basename}.key"
  fi
  _target_root_pem_path="$(dirname ${_target_root_crt_path})/${_cert_basename}.pem"

  mkdir -p "$(dirname ${_target_root_crt_path})"

  if [[ "$(is_docker_container_running 'nginx-reverse-proxy')" == "1" ]]; then
    local _openssl_command
    _openssl_command="mkdir -p /tmp/DevboxRootCA && \
      openssl req -x509 \
      -nodes -new -sha256 -days 1024 \
      -newkey rsa:2048 \
      -keyout /tmp/DevboxRootCA/${_cert_basename}.key \
      -out /tmp/DevboxRootCA/${_cert_basename}.pem \
      -subj /C=BY/ST=Minsk/L=Minsk/O=EwaveDevOpsTeam_Devbox/CN=DevboxRootCA/ \
      >/dev/null 2>&1 && \
      openssl x509 -outform pem -in /tmp/DevboxRootCA/${_cert_basename}.pem -out /tmp/DevboxRootCA/${_cert_basename}.crt \
      >/dev/null 2>&1"

    docker exec -it 'nginx-reverse-proxy' /bin/bash -c "${_openssl_command}"

    if [[ "$?" != "0" ]]; then
      show_error_message "Unable to generate Root CA certificate. An error occurred during generation."
      exit 1
    fi

    docker cp "nginx-reverse-proxy:/tmp/DevboxRootCA/${_cert_basename}.crt" "${_target_root_crt_path}"
    docker cp "nginx-reverse-proxy:/tmp/DevboxRootCA/${_cert_basename}.pem" "${_target_root_pem_path}"
    docker cp "nginx-reverse-proxy:/tmp/DevboxRootCA/${_cert_basename}.key" "${_target_root_key_path}"
    docker exec -it 'nginx-reverse-proxy' /bin/bash -c "rm -rf /tmp/DevboxRootCA"
  else
    show_error_message "Unable to generate Root CA certificate. Nginx-reverse-proxy container for generating is not running."
    exit 1
  fi
}

function ssl_generate_domain_certificate() {
  local _website_name=${1-''}
  local _extra_domains=${2-''}
  local _target_crt_path=${3-''}
  local _target_key_path=${4-''}
  local _root_ca_pem_path=${5-''}
  local _root_ca_key_path=${6-''}

  if [[ -z "${_website_name}" ]]; then
    show_error_message "Unable to generate website SSL certificate. Website name cannot be empty."
    exit 1
  fi

  if [[ -z "${_target_crt_path}" ]]; then
    show_error_message "Unable to generate website SSL certificate. Target path of certificate cannot be empty."
    exit 1
  fi

  if [[ -z "${_root_ca_pem_path}" ]]; then
    show_error_message "Unable to generate website SSL certificate. Root CA cannot be empty."
    exit 1
  fi

  local _cert_basename
  _cert_basename=$(basename ${_target_crt_path} '.crt')

  if [[ -z "${_target_key_path}" ]]; then
    _target_key_path="$(dirname ${_target_crt_path})/${_cert_basename}.key"
  fi

  if [[ -z "${_root_ca_key_path}" ]]; then
    _root_ca_key_path="$(dirname ${_root_ca_pem_path})/$(basename ${_root_ca_pem_path} '.pem').key"
  fi

  mkdir -p "$(dirname ${_target_crt_path})"

  if [[ "$(is_docker_container_running 'nginx-reverse-proxy')" == "1" ]]; then
    _ext_content="authorityKeyIdentifier=keyid,issuer\n"
    _ext_content="${_ext_content}basicConstraints=CA:FALSE\n"
    _ext_content="${_ext_content}keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n"
    _ext_content="${_ext_content}subjectAltName = @alt_names\n"
    _ext_content="${_ext_content}[alt_names]\n"
    _ext_content="${_ext_content}DNS.1 = ${_website_name}"

    if [[ ! -z "${_extra_domains}" ]]; then
      _counter=2
      for _domain in $(echo "${_extra_domains}" | tr ', ' ' '); do
        _ext_content="${_ext_content}\nDNS.${_counter} = ${_domain}"
        ((_counter++))
      done
    fi

    docker cp "${_root_ca_pem_path}" "nginx-reverse-proxy:/tmp/DevBoxRootCa.pem"
    docker cp "${_root_ca_key_path}" "nginx-reverse-proxy:/tmp/DevBoxRootCa.key"

    local _openssl_command
    _openssl_command="[ ! -f /root/.rnd ] && openssl rand -writerand /root/.rnd >/dev/null 2>&1 || true; \
        echo -e '${_ext_content}' > /tmp/${_website_name}.ext && \
        openssl req -new -nodes \
          -newkey rsa:2048 \
          -keyout /tmp/${_cert_basename}.key \
          -out /tmp/${_cert_basename}.csr \
          -subj '/C=BY/ST=Minsk/L=Minsk/O=EwaveDevOpsTeam_Devbox/CN=${_website_name}' \
        >/dev/null 2>&1 && \
        openssl x509 -req \
          -sha256 \
          -days 1024 \
          -in /tmp/${_cert_basename}.csr \
          -CA /tmp/DevBoxRootCa.pem \
          -CAkey /tmp/DevBoxRootCa.key \
          -CAcreateserial \
          -extfile /tmp/${_website_name}.ext \
          -out /tmp/${_cert_basename}.crt \
        >/dev/null 2>&1"

    docker exec -it 'nginx-reverse-proxy' /bin/bash -c "${_openssl_command}"

    if [[ "$?" != "0" ]]; then
      show_error_message "Unable to generate CA certificate. An error occurred during generation. See command output above."
      exit 1
    fi

    docker cp "nginx-reverse-proxy:/tmp/${_cert_basename}.crt" "$_target_crt_path"
    docker cp "nginx-reverse-proxy:/tmp/${_cert_basename}.key" "$_target_key_path"
    docker exec -it 'nginx-reverse-proxy' /bin/bash -c "rm -f /tmp/{${_cert_basename}.crt,${_cert_basename}.key,${_cert_basename}.csr,${_cert_basename}.ext,DevBoxRootCa.pem,DevBoxRootCa.key,DevBoxRootCa.srl}"
  else
    show_error_message "Unable to generate CA certificate. Nginx-reverse-proxy container for generating is not running."
    exit 1
  fi
}

############################ Public functions end ############################
