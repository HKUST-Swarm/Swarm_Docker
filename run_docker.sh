#!/usr/bin/env bash
trap : SIGTERM SIGINT

# [ "$UID" -eq 0 ] || exec sudo "$0" "$@"

source /home/dji/SwarmConfig/image_config.sh
CONFIG_PATH=/home/dji/SwarmConfig
source $CONFIG_PATH/configs.sh

#print help
function echoUsage()
{
    echo -e "Usage: ./run_docker.sh [FLAG] \n\
            \t -r read from SwarmConfig to execute \n\
            \t -e edit docker container \n\
            \t -s run docker program only
            \t -h help" >&2
}
if [ "$#" -lt 1 ]; then
  echoUsage
  exit 1
fi

RUN=0;
EDIT=0;
PULL=0;
HOST=0

while getopts "ehsrdpu" opt; do
    case "$opt" in
        h)
            echoUsage
            exit 0
            ;;
        r)  RUN=1
            HOST=1
            ;;
        e)  EDIT=1
            ;;
        s)  RUN=1
            ;;
        *)
            echoUsage
            exit 1
            ;;
    esac
done

if [ $EDIT -eq 1 ]; then
    sudo xhost +si:localuser:root
    nvidia-docker run \
            -v /home/dji/Swarm_Docker/:/root/Swarm_Docker/ \
	    -v /root/.ros/log:/root/.ros/log \
            -v /home/dji/SwarmConfig:/home/dji/SwarmConfig \
            -v /home/dji/SwarmConfig:/root/SwarmConfig \
            -v /ssd:/ssd \
            -v /usr/include/:/usr/include/ \
            -v /etc/alternatives/:/etc/alternatives/ \
            -v /ssd/swarm_ws_build_docker:/root/swarm_ws/build \
            -e DISPLAY=$DISPLAY \
            --volume="/etc/group:/etc/group:ro" \
            --volume="/etc/shadow:/etc/shadow:ro" \
            --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
            --name=swarm \
            --user 0 \
            --net=host \
            --rm \
            --privileged -v /dev/:/dev/ \
            -it ${DOCKER_IMAGE} \
            /bin/zsh

elif [ $RUN -eq 1 ]; then


    if [ "$#" -ge 2 ]; then
        export SWARM_START_MODE=$2
    fi

    echo "Start swarm with MODE" $2

    if [ $SWARM_START_MODE -ge 0 ]
    then
        echo "Will start docker.."
    else
        exit 0
    fi

    if [ $HOST -eq 1 ] 
    then
        echo "Start host program"
        /home/dji/Swarm_Docker/run_host.sh
    else
        echo "Start docker program only"
    fi
    
    echo "Start NVIDIA DOCKER"
    nvidia-docker run -it \
            -v /root/.ros/log/:/root/.ros/log/ \
            -v /ssd:/ssd \
            -v /home/dji:/home/dji \
            -v /home/dji/Swarm_Docker:/root/Swarm_Docker \
            -v /ssd/swarm_ws_build_docker:/root/swarm_ws/build \
            -v /home/dji/SwarmConfig:/root/SwarmConfig \
            --rm \
            --env="DISPLAY" \
            -e LOG_PATH=$LOG_PATH \
            -e ROS_MASTER_URI=$ROS_MASTER_URI \
            --volume="/etc/group:/etc/group:ro" \
            --volume="/etc/shadow:/etc/shadow:ro" \
            --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
            --net=host \
            --name=swarm \
            --user 0 \
            --privileged -v /dev/:/dev/ \
            -d \
            --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
            ${DOCKER_IMAGE} \
            /root/Swarm_Docker/docker_run_script.sh &
    /bin/sleep 20
    
    echo "Record bag:", $RECORD_BAG
    /home/dji/Swarm_Docker/run_bag_record.sh
fi
