#!/usr/bin/env bash
set -eu
#Variables
source ./tools/main.sh
source ./tools/install_dependency.sh
source ./tools/devbox_infrastructure.sh
source ./tools/env_file.sh
source ./tools/free_port.sh
source ./tools/web_platform.sh
source ./tools/domain.sh
source ./tools/restart_service.sh
source ./tools/bash_alias.sh
source ./tools/fix.sh
source ./tools/print_info.sh

#  Total: Run only one function
stop_menu
