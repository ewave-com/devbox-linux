#!/bin/bash
fix_permissions(){
sudo docker exec -it "$PROJECT_NAME"_"$CONTAINER_WEB_NAME" /bin/bash -c "/usr/bin/php $TOOLS_PROVIDER_REMOTE_PATH/$TOOLS_PROVIDER_ENTRYPOINT core:setup:permissions"
}
