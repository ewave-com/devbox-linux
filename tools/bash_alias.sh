#!/bin/bash
addToolsAlias(){
sudo docker exec -it "$PROJECT_NAME"_"$CONTAINER_WEB_NAME" /bin/bash -c "echo 'alias platform-tools='\'/usr/bin/php $TOOLS_PROVIDER_REMOTE_PATH/$TOOLS_PROVIDER_ENTRYPOINT\''' >> ~/.bashrc"
sudo docker exec -it "$PROJECT_NAME"_"$CONTAINER_WEB_NAME" /bin/bash -c "echo 'alias platform-tools='\'/usr/bin/php $TOOLS_PROVIDER_REMOTE_PATH/$TOOLS_PROVIDER_ENTRYPOINT\''' >> /var/www/.bashrc && chown -R www-data:www-data /var/www/.bashrc"
}