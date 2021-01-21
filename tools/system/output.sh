#!/usr/bin/env bash

require_once "${devbox_root}/tools/system/constants.sh"

############################ Public functions ############################

function show_error_message() {
  local _message=${1-""}
  local _hierarchy_lvl=${2-"0"}

  _prefix="$(get_hierarchy_lvl_prefix ${_hierarchy_lvl})"
  echo -e "${RED}${_prefix}${_message}${SET}"
}

function show_warning_message() {
  local _message=${1-""}
  local _hierarchy_lvl=${2-"0"}

  _prefix="$(get_hierarchy_lvl_prefix ${_hierarchy_lvl})"
  echo -e "${YELLOW}${_prefix}${_message}${SET}"
}

function show_success_message() {
  local _message=${1-""}
  local _hierarchy_lvl=${2-"0"}

  _prefix="$(get_hierarchy_lvl_prefix ${_hierarchy_lvl})"
  echo -e "${GREEN}$(date) ${_prefix}${_message}${SET}"
}

function show_message() {
  local _message=${1-""}
  local _hierarchy_lvl=${2-"0"}

  _prefix="$(get_hierarchy_lvl_prefix ${_hierarchy_lvl})"
  echo -e "${SET}${_prefix}${_message}${SET}"
}

function show_info_value_message() {
  local _message=$1
  local _value=$2

  echo -e "${GREEN}${_message}: ${SET}${_value}"
}

function print_section_header() {
  local _header=$1

  print_filled_line "" "80" "="
  print_filled_line "${_header}" "80" ' '
  print_filled_line "" "80" "="
}

function print_section_footer() {
  print_filled_line "" "80" "="
}

############################ Public functions end ############################

############################ Local functions ############################

function print_filled_line() {
  local _string=${1-""}
  local _total_length=${2-"80"}
  local _filler_char=${3-"\055"} #\055 equals hyphen char, pass code for correct parsing by 'printf'

  # ${#string} expands to the length of $string
  local _string_length
  _string_length=${#_string}
  local _filler_length
  local _filler

  if [[ ${_string_length} != 0 ]]; then
    _filler_length=$(((${_total_length} - ${_string_length} - 2) / 2))
    _filler=$(printf "${_filler_char}%.0s" $(seq 1 ${_filler_length}))
    # add extra filler to align header and footer for strings with odd length
    if [ $((_string_length % 2)) -eq 0 ]; then _extra_filler=""; else _extra_filler=${_filler_char}; fi
    echo -e "${_filler} ${GREEN}${_string}${SET} ${_filler}${_extra_filler}"
  else
    echo -e "$(printf "${_filler_char}%.0s" $(seq 1 "${_total_length}"))"
  fi
}

function get_hierarchy_lvl_prefix() {
  local _level=${1-"0"}

  if [[ "${_level}" == "0" ]]; then
    echo ""
  fi

  _prefix=""
  case $_level in
  "1") _prefix=" > " ;;
  "2") _prefix="    * " ;;
  "3") _prefix="      * " ;;
  *) _prefix="" ;;
  esac

  echo "${_prefix}"
}

############################ Local functions end ############################
