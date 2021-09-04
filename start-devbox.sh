#!/usr/bin/env bash
set -eu       # Normal working mode
#set -eux     # Verbose debug mode

# 'realpath' might be not installed
if [[ ! -z "$(which realpath)" ]]; then
  devbox_root=$(realpath $(dirname "${BASH_SOURCE[0]}"))
else
  devbox_root=`dirname "$0"`
  [[ "${devbox_root}" == "." ]] && devbox_root="${PWD}"
fi
export devbox_root

# bash version must be 3.0+ for proper work of devbox
source "${devbox_root}/tools/system/check-bash-version.sh"

source "${devbox_root}/tools/system/require-once.sh"

require_once "${devbox_root}/tools/system/dependencies-installer.sh"
require_once "${devbox_root}/tools/main.sh"
require_once "${devbox_root}/tools/menu/select-project.sh"

cat ${devbox_root}/tools/print/logo.txt

install_dependencies
update_docker_images_if_required

# You can pass project name as argument to start without additional selecting
selected_project=${1-""}
# Select folder with project
if [[ -z "${selected_project}" ]]; then
  select_project_menu "selected_project"
fi

_no_interaction="0"
if [[ "${2-''}" == "-n" || "${2-''}" == "--no-interaction" ]]; then
  _no_interaction="1"
fi

start_devbox_project "${selected_project}" "${_no_interaction}"

cat ${devbox_root}/tools/print/done.txt
