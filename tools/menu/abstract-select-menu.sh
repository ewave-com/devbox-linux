#!/usr/bin/env bash
# Copyright (C) 2017 Ingo Hollmann - All Rights Reserved
# Permission to copy and modify is granted under the Creative Commons Attribution 4.0 license
# Last revised 2017-09-08
# Source link
# https://www.bughunter2k.de/blog/cursor-controlled-selectmenu-in-bash

# Modified by eWave for DevBox

require_once ${devbox_root}/tools/system/output.sh

############################ Public functions ############################

select_menu_item() {
  if [[ "${BASH_VERSION}" =~ ^[1-3]\. ]]; then
    show_warning_message "Menu will be slow because of limitations of old BASH version. Your version: ${BASH_VERSION}. Recommended version is 4.0+."
    if [[ -f "/usr/local/bin/bash" && "$(/usr/local/bin/bash -c 'echo $BASH_VERSION')" =~ ^[5-9]\. ]]; then
      show_warning_message "Recommeded BASH version found at path \"/usr/local/bin/bash\" but not used by default."
      show_warning_message "You migth enable BASH version \"$(/usr/local/bin/bash -c 'echo $BASH_VERSION')\" by default executing command \"chsh -s /usr/local/bin/bash\""
    fi
  fi

  declare -a menu
  local _menu_string=$1
  local _return_into_var=${2-"selected_menu_item"}
  local _menu_delimiter=${3-" "}

  if [[ -z "${_menu_string}" ]]; then
    show_error_message "Unable to draw menu. Initial items not given."
    exit 1
  fi

  IFS="${_menu_delimiter}" read -a menu <<<"${_menu_string}"

  cursor=0

  draw_menu() {
    for i in "${!menu[@]}"; do
      if [[ ${cursor} == $i ]]; then
        tput setaf 2
        echo " > [$i] ${menu[${i}]}"
        tput sgr0
      else
        echo "   [$i] ${menu[${i}]}"
      fi
    done
  }

  clear_menu() {
    # move cursor to the beginning of the list
    for i in "${menu[@]}"; do
      tput cuu1
    done
    # clear screen till the end
    tput ed || tput cd
  }

  # Draw initial Menu
  draw_menu
  while read -sn1 key; do # 1 char (not delimiter), silent
    # Check for enter/space (\x0A - enter, \x20 - space)
    if [[ "${key}" == $'\x0A' || "${key}" == $'\x20' || "${key}" == '' ]]; then break; fi
    # Allow type numeric index of selection
    if [[ ${key} =~ ^[0-9]+$ ]]; then
      if [[ "${menu[${key}]+x}" = "x" ]]; then
        cursor=$key
      elif [[ "${cursor}" != "0" && "${menu[${cursor}${key}]+x}" = "x" ]]; then
        cursor=${cursor}${key}
      fi
    else
      # catch multi-char special key sequences
      # BASH_VERSION < 4.0 doesnt have a fractional timeout of key stroke, so we use long reading to avoid command fatal
      if [[ ! "${BASH_VERSION}" =~ ^[1-3]\. ]]; then
        read -s -n 1 -t 0.0001 k1 || true
        read -s -n 1 -t 0.0001 k2 || true
        read -s -n 1 -t 0.0001 k3 || true
      else
        read -s -n 1 -t 1 k1 || true
        read -s -n 1 -t 1 k2 || true
        read -s -n 1 -t 1 k3 || true
      fi

      key+=${k1-''}${k2-''}${k3-''}
    fi

    case "$key" in
    # cursor up, left: previous item
    i | j | $'\e[A' | $'\e0A' | $'\e[D' | $'\e0D') ((((cursor > 0)) && ((cursor--)))) || true ;;
    # cursor down, right: next item
    k | l | $'\e[B' | $'\e0B' | $'\e[C' | $'\e0C') ((((cursor < ${#menu[@]} - 1)) && ((cursor++)))) || true ;;
      # Home, PgUp keys: first item
    $'\e[1~' | $'\e0H' | $'\e[H' | $'\e05~' | $'\e[5~') cursor=0 ;;
      # End, PgDown keys: last item
    $'\e[4~' | $'\e0F' | $'\e[F' | $'\e06~' | $'\e[6~') ((cursor = ${#menu[@]} - 1)) ;;
      # q, carriage return: quit
    q | '' | $'\e') echo "exit" && exit ;
    esac
    # Redraw menu
    clear_menu
    draw_menu
  done

  eval ${_return_into_var}"=\"${menu[$cursor]}\""
}

############################ Public functions end ############################
