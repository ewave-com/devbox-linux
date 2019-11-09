#!/usr/bin/env bash

# The script is required only to kill all containers. Possible usecase - unexpected shutdown.
# Please use down-devbox.sh to shutdown projects properly.

if [ $(docker ps -aq | wc -l) -eq 0 ]; then
  echo "Nothing to kill"
  exit 0
fi


docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
