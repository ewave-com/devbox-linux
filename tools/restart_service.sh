#!/bin/bash
nginx_reverse_proxy_restart(){
sleep 5;
#Fix for reload network
#Because devbox-network contains all containers
sudo docker restart nginx-reverse-proxy
}
