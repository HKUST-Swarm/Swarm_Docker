#!/bin/bash
#echo "pull imagestart" >> /home/dji/log.txt
source /home/dji/SwarmConfig/configs.sh

sudo -S sh -c 'echo 2048 > /sys/module/usbcore/parameters/usbfs_memory_mb'

if [ $CONFIG_NETWORK -eq 1 ]; then
    /home/dji/Swarm_Docker/setup_adhoc.sh $DRONE_ID &
    echo "Wait 10 for network setup"
    /bin/sleep 10
fi

if [ $PULL_DOCKER -eq 1 ]; then
    /bin/bash /home/dji/Swarm_Docker/pull_docker.sh > /home/dji/log.txt
fi 

if [ $START_DOCKER -eq 1 ]; then
    /bin/bash /home/dji/Swarm_Docker/run_docker.sh -r >>/home/dji/log.txt &
fi

echo "start swarmstart" >> /home/dji/log.txt
