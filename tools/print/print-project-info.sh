#!/usr/bin/env bash

require_once ${devbox_root}/tools/system/output.sh

print_info() {
  echo -e ""
  echo -e "-----------------------------------------------------------------------"
  echo -e " * * * * * * * $GREEN URL's, ports and container names  $SET * * * * * * * * "
  echo -e "-----------------------------------------------------------------------\n"

  echo -e "--------------------------$GREEN SERVICES $SET-----------------------------------"
  show_info_value_message "Mailhog URL" "http://127.0.0.1:8025"
  show_info_value_message "Portainer URL" "http://127.0.0.1:9999"
  echo -e "-----------------------------------------------------------------------\n"

  echo -e "--------------------------$GREEN WEB $SET----------------------------------------"
  show_info_value_message "Project name URL" "${WEBSITE_PROTOCOL}://${WEBSITE_HOST_NAME}"
  show_info_value_message "Web container" "${PROJECT_NAME}_${CONTAINER_WEB_NAME}"

  echo -e "-----------------------------------------------------------------------\n"

  if [[ ${MYSQL_ENABLE} == yes ]]; then
    print_section_header "MYSQL"
    show_info_value_message "MYSQL container" "${PROJECT_NAME}_${CONTAINER_MYSQL_NAME}"
    show_info_value_message "MYSQL connect" "[from LOCAL PC]"
    show_info_value_message "Server IP" "127.0.0.1"
    show_info_value_message "Server Port" "${CONTAINER_MYSQL_PORT}"
    show_info_value_message "Credentials" "root / ${CONTAINER_MYSQL_ROOT_PASS}"
    show_info_value_message "MYSQL connect [from containers]" "mysql -uroot -p${CONTAINER_MYSQL_ROOT_PASS} -hdb ${PROJECT_NAME}"
    print_section_footer
  fi

  if [[ ${VARNISH_ENABLE} == yes ]]; then
    print_section_header "VARNISH"
    show_info_value_message "Varnish container" "${PROJECT_NAME}_${CONTAINER_VARNISH_NAME}"
    print_section_footer
  fi

  if [[ ${REDIS_ENABLE} == yes ]]; then
    print_section_header "REDIS"
    show_info_value_message "Redis container" "${PROJECT_NAME}_${CONTAINER_REDIS_NAME}"
    print_section_footer
  fi

  if [[ ${ELASTICSEARCH_ENABLE} == yes ]]; then
    print_section_header "ELASTICSEARCH"
    show_info_value_message "ElasticSearch container" "${PROJECT_NAME}_${CONTAINER_ELASTICSEARCH_NAME}"
    print_section_footer
  fi

  if [[ ${BLACKFIRE_ENABLE} == yes ]]; then
    print_section_header "BLACKFIRE"
    show_info_value_message "Blackfire container" "${PROJECT_NAME}_${CONTAINER_BLACKFIRE_NAME}"
    print_section_footer
  fi

  print_section_header "ALL CONTAINERS"
  sudo docker ps --format '{{.Names}}'
  print_section_footer
}
