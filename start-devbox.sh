#!/usr/bin/env bash
set -eu

export devbox_root=$(realpath $(dirname "${BASH_SOURCE[0]}")) || $(pwd)

# bash version must be 3.0+ for proper work of devbox
source "${devbox_root}/tools/system/check-bash-version.sh"

source "${devbox_root}/tools/system/require-once.sh"

require_once "${devbox_root}/tools/system/dependencies-installer.sh"
require_once "${devbox_root}/tools/main.sh"
require_once "${devbox_root}/tools/menu/select-project.sh"

cat ${devbox_root}/tools/print/logo.txt

install_dependencies

# You can pass project name as argument to start without additional selecting
selected_project=${1-""}
# Select folder with project
if [[ -z "${selected_project}" ]]; then
  select_project_menu "selected_project"
fi

start_devbox_project "${selected_project}"

cat ${devbox_root}/tools/print/done.txt
