#!/bin/bash
source /home/dji/SwarmConfig/configs.sh
source /home/dji/Swarm_Docker/image_config.sh
IMAGE_ID="$(docker inspect --format='{{.Image}}' $(docker ps -aq))"
FW_URL="http://${MANAGER_SERVER}/push/$DRONE_ID/$IMAGE_ID"

if [ "$#" -eq 0 ];then
    echo "Commit&Push to i7 server with name as" ${SERVER_IMAGE}
    docker commit swarm ${SERVER_IMAGE}
    docker push ${SERVER_IMAGE}
    wget -qO- ${FW_URL} &
else
    echo "Commit&Push to remote hub as"${REMOTE_IMAGE}
    docker commit swarm ${REMOTE_IMAGE}
    docker push ${REMOTE_IMAGE}
fi

