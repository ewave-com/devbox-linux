#!/usr/bin/env bash

require_once ${devbox_root}/tools/system/constants.sh
require_once ${devbox_root}/tools/system/output.sh

############################ Public functions ############################

is_docker_container_running() {
  local _container_name=$1
  if [[ ! -z $(docker ps -a --filter="name=${_container_name}" --filter="status=running" --format="{{.Names}}") ]]; then
    echo "1"
  else
    echo "0"
  fi
}

is_docker_container_exist() {
  local _container_name=$1
  if [[ ! -z $(docker ps -a --filter="name=${_container_name}" --format="{{.Names}}") ]]; then
    echo "1"
  else
    echo "0"
  fi
}

kill_container_by_name() {
  local _container_name=$1
  local _force=${2-"0"}
  local _signal=${3-"SIGKILL"}

  if [[ "${_force}" == "1" ]]; then
    docker kill $(docker ps -aq --filter="name=${_container_name}") -s ${_signal} --force > /dev/null
  else
    docker kill $(docker ps -aq --filter="name=${_container_name}") -s ${_signal} > /dev/null
  fi
}

rm_container_by_name() {
  local _container_name=$1
  local _force=${2-"0"}

  if [[ "${_force}" == "1" ]]; then
    docker rm $(docker ps -aq --filter="name=${_container_name}") --force > /dev/null 2>&1
  else
    docker rm $(docker ps -aq --filter="name=${_container_name}") > /dev/null 2>&1
  fi
}

############################ Public functions end ############################
