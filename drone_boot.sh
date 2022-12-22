#!/bin/bash
#echo "pull imagestart" >> /home/dji/log.txt
source /home/dji/SwarmConfig/configs.sh
source /home/dji/SwarmConfig/drone_private_config.sh

if [ $ENABLE_ADHOC -eq 1 ]; then
    echo "Wait 10 to setup adhoc"
    /bin/sleep 10
    /home/dji/Swarm_Docker/setup_adhoc.sh $DRONE_ID &
    echo "Wait 5 for network setup"
    /bin/sleep 5
fi

if [ $MASTER_CONTROL -eq 1 ]; then
    if [ $PULL_DOCKER -eq 1 ]; then
        /bin/bash /home/dji/Swarm_Docker/pull_docker.sh > /home/dji/log.txt
    fi 

    if [ $START_HOST -eq 1 ] 
    then
        echo "Start host program"
        /home/dji/Swarm_Docker/run_host.sh
    else
        echo "Start docker program only"
    fi

    if [ $START_DOCKER -eq 1 ]; then
        /bin/bash /home/dji/Swarm_Docker/run_docker.sh -r >>/home/dji/log.txt &
    else 
        echo "Record bag:", $RECORD_BAG
        /home/dji/Swarm_Docker/run_bag_record.sh
    fi
    echo "Finish swarmstart" >> /home/dji/log.txt
fi
