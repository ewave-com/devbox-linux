#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

function add_website_domain_to_hosts() {
  local _domains=${1-''} # comma-separated list
  local _ip_address=${3-"127.0.0.1"}

  if [[ -z "${_domains}" ]]; then
    show_error_message "Unable to add website to hosts file. Website domain cannot be empty"
    exit 1
  fi

  for _domain in $(echo "${_domains}" | tr ', ' ' '); do
    # Add site to file hosts, if doesn't exist
    local _hosts_record
    _hosts_record="${_ip_address} ${_domain}"
    if [[ -z $(cat /etc/hosts | grep "^${_hosts_record}$" | head -n 1) ]]; then
      sudo -- sh -c -e "echo '${_hosts_record}' >> /etc/hosts"
    fi
  done
}

function delete_website_domain_from_hosts() {
  local _domains=${1-''} # comma-separated list
  local _ip_address=${2-"127.0.0.1"}

  if [[ -z "${_domains}" ]]; then
    show_error_message "Unable to remove website from hosts file. Website domain cannot be empty"
    exit 1
  fi

  for _domain in $(echo "${_domains}" | tr ', ' ' '); do
    local _hosts_record
    _hosts_record="${_ip_address} ${_domain}"
    if [[ ! -z $(cat /etc/hosts | grep "^${_hosts_record}$" | head -n 1) ]]; then
      if [[ "${os_type}" == "macos" ]]; then
        # MacOs specific, "sed -i" requires empty file suffix to update file in place, so set "sed -i ''"
        sudo -- sh -c -e "sed -i '' '/${_hosts_record}/d' /etc/hosts" >/dev/null #2>&1
      elif [[ "${os_type}" == "linux" ]]; then
        sudo -- sh -c -e "sed -i '/${_hosts_record}/d' /etc/hosts" >/dev/null #2>&1
      fi
    fi
  done
}

############################ Public functions end ############################
