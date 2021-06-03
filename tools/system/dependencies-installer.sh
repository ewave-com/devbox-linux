#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"
require_once "${devbox_root}/tools/system/output.sh"

############################ Public functions ############################

export devbox_env_path_updated="0"

function install_dependencies() {
  show_success_message "Validating software dependencies"

  install_docker
  install_docker_sync
#  install_unison # not needed because of native sync, you can install and try to use it, but this way was not tested
  install_git
  install_composer
  install_extra_packages
  register_devbox_scripts_globally

  if [[ "${devbox_env_path_updated}" == "1" ]]; then
    show_warning_message "###########################################################################################"
    show_success_message "Installed packages updated your PATH system variable."
    show_warning_message "!!! To apply changes please close this window and start again using new console window !!!."
    show_warning_message "###########################################################################################"
    unset_flag_terminal_restart_required
    exit
  fi
  unset_flag_terminal_restart_required
}

############################ Public functions end ############################

############################ Local functions ############################

# Check and install docker
function install_docker() {
  local _docker_location=$(which docker)
  local _docker_compose_location=$(which docker-compose)
  if [[ -n "${_docker_compose_location}" ]]; then
    local _compose_version="$(docker-compose --version | cut -d " " -f 3 | cut -d "," -f 1)"
    _compose_min_version="1.25.0"
    # --env-file available since docker-compose 1.25.
    # https://stackoverflow.com/questions/40525230/specify-the-env-file-docker-compose-uses
    if [[ ! "$(printf '%s\n' "${_compose_min_version}" "${_compose_version}" | sort -V | head -n1)" == "${_compose_min_version}" ]]; then
      show_warning_message "You are running docker-compose version ${_compose_version}. DevBox requires version ${_compose_min_version} or higher."
      show_warning_message "Docker and docker-compose will be updated automatically. This is one-time operation."
      sudo rm -rf "${_docker_compose_location}"
      _docker_compose_location=""
    fi
  fi

  if [[ -z "${_docker_location}" || -z "${_docker_compose_location}" ]]; then
    # Removing docker-engine if exists
    sudo apt-get -y remove docker docker-engine docker.io >/dev/null                                                                                                  #2>&1
    # Install prerequisites to install docker
    sudo apt-get install -y apt-transport-https ca-certificates curl jq software-properties-common net-tools wget mc htop dstat libnss3-tools jq net-tools >/dev/null #2>&1
    # Add repo docker CE
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >/dev/null #2>&1
    # Install docker gpg key
    sudo curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | sudo apt-key add - >/dev/null      #2>&1
    #Install docker-ce
    sudo apt-get -qq update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io >/dev/null #2>&1
    #Install last version docker-compose
    if [[ ! -f /usr/local/bin/docker-compose ]]; then
      docker_compose_version=$(curl --silent "https://api.github.com/repos/docker/compose/releases/latest" | jq .name -r)
      sudo curl -q -L "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose \
        >/dev/null #2>&1
      sudo chmod +x /usr/local/bin/docker-compose
    fi
    # Set permission
    sudo usermod -a -G docker "${host_user}"
    sudo chown "${host_user}":"${host_user_group}" "/home/${host_user}/.docker" -R >/dev/null #2>&1
    sudo chmod g+rwx "/home/${host_user}/.docker" -R >/dev/null                               #2>&1
  fi

  if [[ -z $(echo "$(groups)" | grep "docker") ]]; then
    sudo usermod -a -G docker "${host_user}"
  fi
}

function install_docker_sync() {
  if [[ -z "$(which ruby)" || -z "$(which gem)" ]]; then
    # ruby@2.7 required, otherwise (ruby 3.0+) very old docker-sync (like 0.1) is installed from repos instead of needed 0.5.14+
    sudo apt-get install -y ruby2.7 ruby2.7-dev >/dev/null

    set_flag_terminal_restart_required
  fi

  if [[ -z "$(which docker-sync)" ]]; then
    sudo gem install docker-sync -v 0.6 --quiet >/dev/null

    set_flag_terminal_restart_required
  fi

  # sync one of docker-sync files with patched version
  _docker_sync_lib_sources_dir="$(dirname "$(gem which docker-sync)")"
  _target_chsum=$(md5sum "${_docker_sync_lib_sources_dir}/docker-sync/sync_strategy/unison.rb" | awk -F' ' '{print $1}')
  _source_chsum=$(md5sum "${devbox_root}/tools/bin/docker-sync/lib/docker-sync/sync_strategy/unison.rb" | awk -F' ' '{print $1}')
  if [[ "${_target_chsum}" != "${_source_chsum}" ]]; then
    sudo cp -f "${devbox_root}/tools/bin/docker-sync/lib/docker-sync/sync_strategy/unison.rb" "${_docker_sync_lib_sources_dir}/docker-sync/sync_strategy/unison.rb"
  fi
}

function install_unison() {
  if [[ -z "$(which unison)" ]]; then
    sudo apt-get install unison >/dev/null
  fi
}

function install_git() {
  if [[ -z "$(which git)" ]]; then
    sudo apt-get install -y git >/dev/null
  fi
}

# Check and install composer
function install_composer() {
  run_composer_installer() {
    # https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
    composer_expected_checksum="$(curl https://composer.github.io/installer.sig)"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    composer_actual_checksum="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "${composer_expected_checksum}" != "${composer_actual_checksum}" ]; then
      echo >&2 'ERROR: Invalid composer installer checksum'
      rm composer-setup.php
      exit 1
    fi

    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer --quiet >/dev/null
    RESULT=$?
    rm composer-setup.php
    return $RESULT
  }

  if [ -z "$(which composer)" ]; then
    run_composer_installer

    set_flag_terminal_restart_required
  fi

  local _composer_output=''
  if [[ ! -f "${devbox_root}/composer.lock" ]]; then
    show_success_message "Running initial composer install command."
    # locally catch the possible composer error without application stopping
    set +e && _composer_output=$(COMPOSER="${devbox_root}/composer.json" composer install --quiet) && set -e
  elif [[ "${composer_autoupdate}" == "1" && -n $(find "${devbox_root}/composer.lock" -mmin +604800) ]]; then
    show_success_message "Running composer update command to refresh packages. Last run was performed a week ago. Please wait a few seconds"
    set +e && _composer_output=$(COMPOSER="${devbox_root}/composer.json" composer update --quiet) && set -e
  fi

  if [[ $(echo ${_composer_output} | grep "Fatal error") ]]; then
    # PHP 8.0+ Compatibility fix, the following error or similar might occur during composer command.
    # PHP Fatal error:  Uncaught ArgumentCountError: array_merge() does not accept unknown named parameters in /usr/share/php/Composer/DependencyResolver/DefaultPolicy.php:84
    # "composer selfupdate" is errored as well. So we need to completely reinstall composer.
    show_warning_message "An error occurred during \"composer install\" operation."
    show_warning_message "This might be caused you are using PHP 8.0+ on the host system. We will try to update composer version to fix the errors."
    sudo apt-get remove -y composer >/dev/null
    run_composer_installer
  fi
}

function install_extra_packages() {
  if [[ -z "$(which openssl)" ]]; then
    sudo apt-get install -y install openssl >/dev/null
  fi

  if [[ -z "$(which setfacl)" ]]; then
    sudo apt-get install -y install acl >/dev/null
  fi
}

function register_devbox_scripts_globally() {
  sudo chmod ug+x "${devbox_root}/start-devbox.sh"
  sudo chmod ug+x "${devbox_root}/down-devbox.sh"
  sudo chmod ug+x "${devbox_root}/sync-actions.sh"

  add_directory_to_env_path "${devbox_root}"
}

function add_directory_to_env_path() {
  local _bin_dir=${1-''}

  if [[ -z "${_bin_dir}" || ! -d "${_bin_dir}" ]]; then
    show_error_message "Unable to update system PATH. Path to binaries is empty or does not exist '${_bin_dir}'."
  fi

  # add new binaries path to env variables of current shell
  if [[ -z $(echo "${PATH}" | grep "${_bin_dir}" ) ]]; then
    export PATH="${PATH}:${_bin_dir}"

    set_flag_terminal_restart_required
  fi

  # save new binaries path to permanent user env variables storage to avoid cleaning
  if [[ -z $(cat ~/.bashrc | grep "export PATH=" | grep "${_bin_dir}" ) ]]; then
    printf '\n# Devbox Path \n' >> ~/.bashrc
    echo 'export PATH="${PATH}:'${_bin_dir}'"' >> ~/.bashrc

    set_flag_terminal_restart_required
  fi
}

function set_flag_terminal_restart_required() {
  export devbox_env_path_updated="1"
}

function unset_flag_terminal_restart_required() {
  unset devbox_env_path_updated
}

############################ Local functions end ############################
