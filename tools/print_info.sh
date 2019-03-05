#!/bin/bash
print_info(){
echo -e ""
echo -e "-----------------------------------------------------------------------"
echo -e " * * * * * * * $GREEN URL's, ports and container names  $SET * * * * * * * * "
echo -e "-----------------------------------------------------------------------\n"

echo -e "--------------------------$GREEN SERVICES $SET-----------------------------------"
echo -e "$GREEN""Mailhog URL $SET: http://127.0.0.1:8025"
echo -e "$GREEN""Portainer URL $SET: http://127.0.0.1:9999"
echo -e "-----------------------------------------------------------------------\n"

echo -e "--------------------------$GREEN WEB $SET----------------------------------------"
echo -e "$GREEN""Project name URL $SET: "$WEBSITE_PROTOCOL"://$PROJECT_NAME.local"
echo -e "$GREEN""Web container $SET: ""$PROJECT_NAME""_web"

if [[ $VARNISH_ENABLE = yes ]]; then
 echo -e "$GREEN""Varnish container $SET: ""$PROJECT_NAME""_varnish"
fi
echo -e "-----------------------------------------------------------------------\n"

echo -e "--------------------------$GREEN MYSQL $SET--------------------------------------"
echo -e "$GREEN""MYSQL container $SET: ""$PROJECT_NAME""_mysql"
echo -e "$GREEN""MYSQL connect $SET [from LOCAL PC]:"
echo -e "$GREEN""Server IP $SET: 127.0.0.1" 
echo -e "$GREEN""Server Port $SET: $mysql_port"
echo -e "$GREEN""Credentials $SET: root / "$CONTAINER_MYSQL_ROOT_PASS" "
echo -e "$GREEN""MYSQL connect $SET [from containers]: mysql -uroot -p"$CONTAINER_MYSQL_ROOT_PASS" -hdb $PROJECT_NAME"
echo -e "-----------------------------------------------------------------------\n"
if [[ $REDIS_ENABLE = yes ]]; then
 echo -e "--------------------------$GREEN REDIS $SET--------------------------------------"
 echo -e "$GREEN""Redis container $SET: ""$PROJECT_NAME""_redis"
 echo -e "-----------------------------------------------------------------------\n"
fi
if [[ $ELASTIC_ENABLE = yes ]]; then
 echo -e "--------------------------$GREEN ES $SET--------------------------------------"
 echo -e "$GREEN""ES container $SET: ""$PROJECT_NAME""_elastic"
 echo -e "-----------------------------------------------------------------------\n"
fi
echo -e "--------------------------$GREEN ALL CONTAINERS $SET-----------------------------"
sudo docker ps --format '{{.Names}}'
echo -e "-----------------------------------------------------------------------"
}