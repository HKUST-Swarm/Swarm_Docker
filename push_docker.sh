#!/bin/bash
source /home/dji/SwarmConfig/configs.sh
source /home/dji/SwarmConfig/image_config.sh
FW_URL="http://${MANAGER_SERVER}/push/$DRONE_ID/$IMAGE_ID"

echo "Commit&Push ${DOCKER_IMAGE} to my server with name as" ${REMOTE_IMAGE}
docker commit ${CONTAINER_NAME} ${DOCKER_IMAGE}
docker tag ${DOCKER_IMAGE} ${REMOTE_IMAGE}
docker push ${REMOTE_IMAGE}
echo "Request ${FW_URL}"
wget -qO- ${FW_URL} &

