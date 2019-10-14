#!/bin/bash
# Check and install docker
# If docker don't install, script will setup it.
install_docker(){
docker_isinstalled=$(dpkg -l | grep docker | grep ii)
if [ -z "$docker_isinstalled" ];then 
  # Removing docker-engine if exists
  sudo apt-get -y remove docker docker-engine docker.io > /dev/null 2>&1
  # Install prerequisites to install docker
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common net-tools wget mc htop dstat openssl libnss3-tools jq > /dev/null 2>&1
  # Add repo docker CE
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null 2>&1
  # Install docker gpg key
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > /dev/null 2>&1
  #Install docker-ce
  sudo apt-get -qq update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io > /dev/null 2>&1
  #Install last version docker-compose
  if [[ ! -f /usr/local/bin/docker-compose ]]; then
  docker_composer_version=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
  sudo curl -q -L https://github.com/docker/compose/releases/download/"${docker_composer_version}"/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null 2>&1
  sudo chmod +x /usr/local/bin/docker-compose
  fi
  # Set permission
  sudo usermod -a -G docker "$USER"
  sudo chown "$USER":"$USER" /home/"$USER"/.docker -R > /dev/null 2>&1
  sudo chmod g+rwx '/home/"$USER"/.docker' -R > /dev/null 2>&1
fi
}

# Check and install composer
# If php composer don't install, script will setup depends.
install_composer() {
composer_isinstalled=$(which composer)
if [ -z "$composer_isinstalled" ]; then
  sudo add-apt-repository -y ppa:ondrej/php
  sudo apt-get -qq update && sudo apt-get install -y composer
  composer install
else
  composer install
fi
}
