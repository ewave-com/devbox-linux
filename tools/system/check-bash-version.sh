#!/usr/bin/env bash

function check_bash_version() {
  local _RED='\033[0;31m'
  local _SET='\033[0m'
  local _GREEN='\033[1;32m'
  if [[ "${BASH_VERSION}" =~ ^[1-2]\. ]]; then
    echo -e "${_RED} Version of BASH must be 3.0+ for proper DevBox work. Current version: ${BASH_VERSION}. Please update your BASH and try starting again. ${_SET}"

    if [[ "${os_type}" == "macos" ]]; then
      # MacOs specific, update bash from old versions at least to 3.2
      echo "We can update bash version automatically. This is one-time operation."
      read -p "Do you want to update bash automatically[y/n]? " -n 1 -r
      if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
        local _isBrewInstalled=$(which brew)
        if [ -z "${_isBrewInstalled}" ]; then
          #The Ruby Homebrew installer is now deprecated and has been rewritten in Bash
          #ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
          bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install bash
        sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
        chsh -s /usr/local/bin/bash
        echo -e "${_GREEN} Bash updating successfully finished. To apply new version please close this window and start DevBox in a new terminal.${_SET}"
      fi
    fi

    exit 1
  fi
}

function confirm_bash_updating() {
  read -p "Do you want to update bash automatically[y/n]? " -n 1 -r
  echo # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    return 1
  fi
}

check_bash_version
