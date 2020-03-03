#!/bin/bash
source /home/dji/SwarmConfig/autostart_config.sh
REMOTE_IMAGE=xyaoab/swarmuav:fisheye
SERVER_IMAGE=192.168.1.204:5000/swarm:fisheye
IMAGE_ID="$(docker inspect --format='{{.Image}}' $(docker ps -aq))"
if [ "$#" -eq 0 ];then
    echo "Commit&Push to i7 server with name as" ${SERVER_IMAGE}
    docker commit swarm ${SERVER_IMAGE}
    docker push ${SERVER_IMAGE}
    curl http://192.168.1.204/push/$NODE_ID/$IMAGE_ID &
else
    echo "Commit&Push to remote hub as"${REMOTE_IMAGE}
    docker commit swarm ${REMOTE_IMAGE}
    docker push ${REMOTE_IMAGE}
fi

