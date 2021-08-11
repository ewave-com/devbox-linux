#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

# find existing docker images without certain tags and refresh image(':latest' only)
function refresh_existing_docker_images() {
  _docker_images="$(docker image list --filter='reference=*/*:latest' --format='{{.Repository}}')"

  for _docker_image in ${_docker_images}; do
    if [[ -z $(echo $docker_images_autoupdate_skip_images | grep "${_docker_image}") ]]; then
      docker_image_pull "${_docker_image}"
    fi
  done
}

# refresh (pull) the given docker image
function docker_image_pull() {
  local _image_name=${1-""}

  if [[ -z "${_image_name}" ]]; then
    show_error_message "Unable to pull docker image. Name cannot be empty."
    exit 1
  fi

  docker pull "${_image_name}:latest" #-q >/dev/null # pull with explicit output
}

############################ Public functions end ############################
