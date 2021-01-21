#!/usr/bin/env bash

devbox_network_name="docker_projectsubnetwork"

############################ Public functions ############################

create_docker_network() {
  local _network_presented
  _network_presented=$(sudo docker network ls --filter NAME="${devbox_network_name}" --format="{{.Name}}")
  if [[ -z "${_network_presented}" ]]; then
    sudo docker network create "${devbox_network_name}" >/dev/null
  fi
}

remove_docker_network() {
  local _network_presented
  _network_presented=$(sudo docker network ls --filter NAME="${devbox_network_name}" --format="{{.Name}}")
  if [[ -n "${_network_presented}" ]]; then
    sudo docker network rm "${devbox_network_name}" >/dev/null #2>&1
  fi
}

get_docker_network_name() {
  echo "${devbox_network_name}"
}

############################ Public functions end ############################
