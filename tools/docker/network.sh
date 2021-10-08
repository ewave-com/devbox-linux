#!/usr/bin/env bash

devbox_network_name="docker_projectsubnetwork"

############################ Public functions ############################

function create_docker_network() {
  local _network_presented
  _network_presented=$(docker network ls --filter=name="${devbox_network_name}" --format="{{.Name}}")
  if [[ -z "${_network_presented}" ]]; then
    docker network create "${devbox_network_name}" >/dev/null
  fi
}

function remove_docker_network() {
  local _network_presented
  _network_presented=$(docker network ls --filter NAME="${devbox_network_name}" --format="{{.Name}}")
  if [[ -n "${_network_presented}" ]]; then
    docker network rm "${devbox_network_name}" >/dev/null 2>&1
  fi
}

function get_docker_network_name() {
  echo "${devbox_network_name}"
}

############################ Public functions end ############################
