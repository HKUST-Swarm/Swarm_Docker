#!/usr/bin/env bash
trap : SIGTERM SIGINT

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

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

 #-v /dev:/dev \
            #--privileged \
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
            -v /dev/ttyUSB0:/dev/ttyUSB0 \
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
            --privileged -v /dev/bus/usb:/dev/bus/usb \
            -it ${DOCKER_IMAGE} \
            /bin/zsh

elif [ $RUN -eq 1 ]; then


    if [ "$#" -ge 2 ]; then
        export SWARM_START_MODE=$2
    fi

    echo "Start swarm with MODE" $2

    if [ $SWARM_START_MODE -ge 0 ]
    then

        #/home/dji/Swarm_Docker/pull_docker.sh >> /home/dji/log.txt 2>&1
        #echo "Pull docker start"

        # echo "Start ros core"
        # roscore &> $LOG_PATH/log_roscore.txt &
        # echo "roscore:"$! >> $PID_FILE

        #/bin/sleep 5 wait for core
        /bin/sleep 5

        echo "Will start camera"
        export START_CAMERA=1
        export START_UWB_COMM=0
        export START_CONTROL=0
        export START_CAMERA_SYNC=0
        export START_UWB_FUSE=0
        export START_DJISDK=1
        export START_VO=0
        export START_UWB_VICON=0
        export USE_VICON_CTRL=0
        export USE_DJI_IMU=0
        export START_SWARM_LOOP=0

        if [ $SWARM_START_MODE -ge 1 ]
        then
            echo "Will start VO"
            START_VO=1
            START_CAMERA_SYNC=1
            if [ $CAM_TYPE -eq 3 ]
            then
                USE_DJI_IMU=1
            fi
        fi

        if [ $SWARM_START_MODE -ge 2 ]
        then
            echo "Will start Control"
            START_CONTROL=1
        fi

        if [ $SWARM_START_MODE -ge 3 ]
        then
            echo "Will start UWB COMM"
            START_UWB_COMM=1
        fi

        if [ $SWARM_START_MODE -ge 4 ]
        then
            echo "Will start UWB FUSE"
            START_UWB_FUSE=1
        fi

        if [ $SWARM_START_MODE -ge 5 ]
        then
	        echo "Will start swarm loop"
            START_SWARM_LOOP=1
        fi

        if [ $SWARM_START_MODE -eq 8 ]
        then
            echo "Will start Control with VICON odom and disable before"
            START_CONTROL=1
            START_UWB_VICON=1
            START_DJISDK=1
            USE_VICON_CTRL=1

            START_CAMERA=0
            START_UWB_COMM=0
            START_UWB_FUSE=0
            START_VO=0
            START_CAMERA_SYNC=0
        fi

        if [ $SWARM_START_MODE -eq 9 ]
        then
            echo "Use for record bag for dl"
            START_CONTROL=0
            START_UWB_VICON=0
            START_DJISDK=1
            USE_VICON_CTRL=1

            START_CAMERA=1
            START_UWB_COMM=1
            START_UWB_FUSE=0
            START_VO=0
            START_CAMERA_SYNC=0

        fi

        if [ $START_CAMERA -eq 1 ]  && [ $CAM_TYPE -eq 0  ]  ||  [ $START_CONTROL -eq 1  ] || [ $USE_DJI_IMU -eq 1 ]
        then
            export START_DJISDK=1
            echo "Using Ptgrey Camera, USE DJI IMU or using control, will boot dji sdk"
        fi

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
            --privileged -v /dev/bus/usb:/dev/bus/usb \
            -d \
            --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
            ${DOCKER_IMAGE} \
            /bin/bash #&> $LOG_PATH/log_docker.txt &
        # echo "DOCKER RUN:"$!>>$PID_FILE
    sleep 10
    
    nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_ssh.sh"
    
    if [ $START_UWB_COMM -eq 1 ] 
    then
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_uwb_comm.sh"
    fi

    if [ $START_PLAN -eq 1 ]
    then
        echo "start planner"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_plan.sh"
    fi

    if [ $START_UWB_FUSE -eq 1 ]
    then
        echo "Start swarm detector"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_swarm_detection.sh"
    fi

    if [ $START_UWB_FUSE -eq 1 ]
    then
        echo "Start UWB fuse"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_swarm_localization.sh"
    fi

    if [ $START_CONTROL -eq 1 ]
    then
	echo "Start CONTROL (Drone cmd only)"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_control.sh"

    fi

    if [ $START_SWARM_LOOP -eq 1 ]
    then
        echo "Will start swarm loop"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_swarmloop.sh"
        /bin/sleep 60
    fi

    if [ $START_VO -eq 1 ]
    then
        echo "Image ready start VO"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_vo.sh"
    fi
fi
