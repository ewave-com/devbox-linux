#!/bin/bash
#DEBUG_MODE=$("> /dev/null 2>&1") 
# List constants
xdebug_port=9001
docker_compose_log_level=ERROR
export devbox_root=$(pwd)
devbox_infra="$devbox_root/configs/docker/infrastructure"
#Server IP for XDEBUG
server_ip=$(ip addr show docker0 | grep -Po 'inet \K[\d.]+')
#Depricated 
#Waiting https://github.com/docker/for-linux/issues/264
#server_ip=172.17.0.1

# Set color variable
DARKGRAY='\033[1;30m'
RED='\033[0;31m'
LIGHTRED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
SET='\033[0m'
#########################

# Function which find projects in folder
list_projects(){
echo "----------------------------------------------"
echo -e " * * * * * * * $GREEN Select project $SET* * * * * * * * "
echo "----------------------------------------------"
PS3='Please input number  --->:'
list="$(ls "./projects" | sed 's/ /£/'| grep -v ".txt") Exit"
select project_folder in $list
do
  if [ "$project_folder" = "Exit" ] #if user selects Exit, then exit the program
    then
      exit 0
    elif [ -n "$project_folder" ] #if name is valid, shows the files inside
    then
      break
    else #if the number of the choice given by user is wrong, exit
      echo "Invalid choice ($REPLY)!"
  fi
done

if [ ! -f  ./projects/"$project_folder"/.env ]; then
  echo -e "$RED File .ENV not found! Please check! $SET"
  exit 0
fi
}

count_up_project_containers (){
count_containers=$(sudo docker ps -a | grep "$PROJECT_NAME" | wc -l)
if [ $count_containers -ne 0  ]; then
  echo -e "$RED Containers form project "$PROJECT_NAME" is running now $SET"
  echo -e "$RED You cann't run already running containers $SET"
  unset_env
  exit 0
fi
}



stop_menu () {
while :
  do
  echo "----------------------------------------------"
  echo -e " * * * * * * * * $GREEN Stop menu $SET * * * * * * * * * "
  echo "----------------------------------------------"
  echo "[1] Stop ONE project "
  echo "[2] Stop ALL projects"
  echo "[0] Exit/stop"
  echo "----------------------------------------------"
  echo -n "Enter your menu choice [1,2 or 0]:"
  read point
  case $point in
    1) list_projects  ; set_env ; stop_project ; unset_env ;  break ;;
    2) stop_all_projects ; break ;;
    0) exit 0 ;;
   esac
done
}