#!/bin/bash
source /home/dji/SwarmConfig/configs.sh
source /home/dji/SwarmConfig/image_config.sh
IMAGE_ID="$(docker inspect --format='{{.Image}}' $(docker ps -aq))"
FW_URL="http://${MANAGER_SERVER}/push/$DRONE_ID/$IMAGE_ID"

if [ "$#" -eq 0 ];then
    echo "Commit&Push to i7 server with name as" ${DOCKER_IMAGE}
    docker commit swarm ${DOCKER_IMAGE}
    docker push ${DOCKER_IMAGE}
    wget -qO- ${FW_URL} &
else
    docker tag ${DOCKER_IMAGE} ${REMOTE_IMAGE}
    echo "Commit&Push to remote hub as"${REMOTE_IMAGE}
    docker commit swarm ${REMOTE_IMAGE}
    docker push ${REMOTE_IMAGE}
fi

