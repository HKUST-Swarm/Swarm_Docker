#!/bin/bash
#sudo -S sh -c 'echo 2048 > /sys/module/usbcore/parameters/usbfs_memory_mb'
#echo "input is: $1"
export LANG=C

HOSTNAME=8.8.8.8
source /home/dji/SwarmConfig/configs.sh
source /home/dji/Swarm_Docker/image_config.sh
SERVER=1
if [ "$#" -gt 0  ]
then
    echo "Pull from hub"
    IMAGE=$REMOTE_IMAGE
    SERVER=0
else
    echo "Pull from i7"
    IMAGE=$DOCKER_IMAGE
fi
if ping -c1 8.8.8.8 &>/dev/null
then
echo "`date`--Start pulling docker image" 

if [ $SERVER -eq 1 ]
then
    wget -qO- http://${MANAGER_SERVER}/pull/$DRONE_ID &
fi

docker pull $IMAGE | grep "Image is up to date";

if [ $SERVER -eq 1 ]
    then
        echo "Send OK"
        wget -qO- http://${MANAGER_SERVER}/ok/$DRONE_ID &
    fi
    echo "up to date" 
else

if [ $SERVER -eq 1 ]
    then
        wget -qO- http://${MANAGER_SERVER}/pull_ok/$DRONE_ID &
fi
echo "pulled new image"
