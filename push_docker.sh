#!/bin/bash
REMOTE_IMAGE=xyaoab/swarmuav:latest
SERVER_IMAGE=192.168.1.204:5000/swarm:latest
if [ "$#" -eq 0 ];then
    echo "Commit&Push to i7 server with name as" ${SERVER_IMAGE}
    docker commit swarm ${SERVER_IMAGE}
    docker push ${SERVER_IMAGE}
else
    echo "Commit&Push to remote hub as"${REMOTE_IMAGE}
    docker commit swarm ${REMOTE_IMAGE}
    docker push ${REMOTE_IMAGE}
fi

