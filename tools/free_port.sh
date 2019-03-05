#!/bin/bash
# Function which find free port for ssh service
ssh_free() {
    ssh_port=$(sudo netstat -tlnp | grep ':230' | awk '{print $4}' | tr -d ':' | sort -g -r | head -n 1);
    if [[ -z "$ssh_port" ]]; then
        ssh_port=2300
    else
        ssh_port=$(($ssh_port +1))
    fi
}

# Function which find free port for mysql service
mysql_free() {
if [[ -z "$CONTAINER_MYSQL_PORT" ]]; then
    mysql_port=$(sudo netstat -tlnp | grep ':::340' | awk '{print $4}' | tr -d ':' | sort -g -r | head -n 1);
    if [[ -z "$mysql_port" ]]; then
        mysql_port=3400
    else
        mysql_port=$(($mysql_port +1))
    fi
else
    mysql_port=$CONTAINER_MYSQL_PORT
fi

#Check filled port from .env if it's free
if [[ ! -z "$CONTAINER_MYSQL_PORT" ]]; then
    mysql_current=$(sudo netstat -tlnp | grep "$CONTAINER_MYSQL_PORT" | awk '{print $4}' | tr -d ':' | sort -g -r | head -n 1);
    if [[ $CONTAINER_MYSQL_PORT=$mysql_current ]]; then
        if [[ ! -z $mysql_current ]]; then
            echo -e "$RED Current MYSQL port $CONTAINER_MYSQL_PORT is using $SET"
            echo -e "$RED Please check variable CONTAINER_MYSQL_PORT in ./projects/"$project_folder"/.env file $SET"
            exit 0;
        fi
    fi
fi

}

#Replace ssh and mysql port in porject docker composer file
sed_ip_port() {
    sed -i 's|%ssh_port%|'$ssh_port'|g' ./projects/"$project_folder"/docker-compose.yml
    sed -i 's|%mysql_port%|'$mysql_port'|g' ./projects/"$project_folder"/docker-compose.yml
}
