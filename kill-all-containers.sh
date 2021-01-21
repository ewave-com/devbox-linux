#!/usr/bin/env bash

# The script is required only to kill all containers. Possible usecase - unexpected shutdown.
# Please use down-devbox.sh to shutdown projects properly.

if [ $(docker ps -aq | wc -l) -eq 0 ]; then
  echo "Nothing to kill"
  exit 0
fi

echo "stopping containers..."
docker stop $(docker ps -aq)

echo "killing containers..."
docker rm $(docker ps -aq)

#echo clearing nginx configs
# copied from win devbox, todo update to linux version
#RMDIR /S /Q \..\..\configs\nginx-reversproxy\run
