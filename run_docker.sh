#!/usr/bin/env bash
trap : SIGTERM SIGINT

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

DOCKER_IMAGE=192.168.1.204:5000/swarm:latest
DOCKER_FISHEYE_IMAGE=192.168.1.204:5000/swarm:fisheye
DOCKER_LOCAL_IMAGE=xyaoab/swarmuav:latest
#print help
function echoUsage()
{
    echo -e "Usage: ./run_docker.sh [FLAG] \n\
            \t -r read from SwarmConfig to execute \n\
            \t -e edit docker container \n\
            \t -d pull docker image from hub \n\
            \t -p pull docker image from private registry \n\
            \t -u update docker image to private registry \n\
            \t -h help" >&2
}
if [ "$#" -lt 1 ]; then
  echoUsage
  exit 1
fi

RUN=0;
EDIT=0;
PULL=0;

while getopts "ehrdpu" opt; do
    case "$opt" in
        h)
            echoUsage
            exit 0
            ;;
        r)  RUN=1
            ;;
        e)  EDIT=1
            ;;
        d)  docker pull ${DOCKER_LOCAL_IMAGE}
            exit 0
            ;;
        p)  docker pull ${DOCKER_IMAGE}
            exit 0
            ;;
        u) docker push swarmuav:latest ${DOCKER_IMAGE}
            exit 0
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
    tx2-docker run \
            --privileged -v /dev/ttyPTGREY:/dev/ttyPTGREY \
            -v /home/dji/.ssh:/root/.ssh \
            --user=$USER \
            --env="DISPLAY" \
            --volume="/etc/group:/etc/group:ro" \
            --volume="/etc/passwd:/etc/passwd:ro" \
            --volume="/etc/shadow:/etc/shadow:ro" \
            --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
            --name swarm \
            --rm \
            -it ${DOCKER_FISHEYE_IMAGE} \
            /bin/zsh

elif [ $RUN -eq 1 ]; then

    echo "Sourceing host machine..."
    source /opt/ros/kinetic/setup.bash
    source /home/dji/swarm_ws/devel/setup.bash

    export ROS_MASTER_URI=http://localhost:11311


    LOG_PATH=/home/dji/swarm_log/`date +%F_%T`
    #LOG_PATH=/ssd/swarm_log/`date +%F_%T`
    CONFIG_PATH=/home/dji/SwarmConfig

    source $CONFIG_PATH/autostart_config.sh

    if [ "$#" -ge 2 ]; then
        export SWARM_START_MODE=$2
        echo "Start swarm with MODE" $2
    fi

    if [ $SWARM_START_MODE -ge 0 ]
    then
        sudo mkdir -p $LOG_PATH
        sudo chmod a+rw $LOG_PATH
        sudo rm /home/dji/swarm_log_lastest
        ln -s $LOG_PATH /home/dji/swarm_log_lastest
        sudo ln -s /root/.ros/log/latest $LOG_PATH

        if [ $CONFIG_NETWORK -eq 1 ]
        then
            /home/dji/SwarmAutoInstall/setup_adhoc.sh $NODE_ID &> $LOG_PATH/log_network.txt &
            echo "Wait 10 for network setup"
            /bin/sleep 10
        fi

        /home/dji/Swarm_Docker/pull_docker.sh >> /home/dji/log.txt 2>&1
        echo "Pull docker start"

        PID_FILE=/home/dji/swarm_log_lastest/pids.txt
        touch $PID_FILE
        echo "Start ros core"
        roscore &> $LOG_PATH/log_roscore.txt &
        echo "roscore:"$! >> $PID_FILE
        #/bin/sleep 5 wait for core
        /bin/sleep 5

        echo "Will start camera"
        export START_CAMERA=1
        export START_UWB_COMM=0
        export START_CONTROL=0
        export START_CAMERA_SYNC=0
        export START_UWB_FUSE=0
        export START_DJISDK=1
        export START_VO_STUFF=0
        export START_UWB_VICON=0
        export USE_VICON_CTRL=0
        export USE_DJI_IMU=0
        export START_SWARM_LOOP=0

        if [ $SWARM_START_MODE -ge 1 ]
        then
            echo "Will start VO"
            START_VO_STUFF=1
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
            START_VO_STUFF=0
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
            START_VO_STUFF=0
            START_CAMERA_SYNC=0

        fi

        if [ $START_CAMERA -eq 1 ]  && [ $CAM_TYPE -eq 0  ]  ||  [ $START_CONTROL -eq 1  ] || [ $USE_DJI_IMU -eq 1 ]
        then
            export START_DJISDK=1
            echo "Using Ptgrey Camera, USE DJI IMUor using control, will boot dji sdk"
        fi

    else
        exit 0
    fi

    echo "PTGREY"$PTGREY_ID
    tx2-docker run \
            --privileged -v /dev/ttyPTGREY:/dev/ttyPTGREY \
            -v /dev/ttyTHS2:/dev/ttyTHS2 \
            -v /home/dji/.ssh:/root/.ssh \
            -v /home/dji/swarm_log:/home/dji/swarm_log \
            -v /root/.ros/log/latest:/root/.ros/log/latest \
            -v $PID_FILE:$PID_FILE \
            -v /home/dji/SwarmConfig:/home/dji/SwarmConfig \
            --rm \
            --user=$USER \
            --env="DISPLAY" \
            --volume="/etc/group:/etc/group:ro" \
            --volume="/etc/passwd:/etc/passwd:ro" \
            --volume="/etc/shadow:/etc/shadow:ro" \
            --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
            -e PID_FILE=$PID_FILE \
            -e LOG_PATH=$LOG_PATH \
            -e START_VO_STUFF=$START_VO_STUFF \
            -e START_CAMERA=$START_CAMERA \
            -e CAM_TYPE=$CAM_TYPE \
            -e START_DJISDK=$START_DJISDK \
            -e START_UWB_VICON=$START_UWB_VICON \
            -e START_UWB_COMM=$START_UWB_COMM \
            -e START_UWB_FUSE=$START_UWB_FUSE \
            -e START_CONTROL=$START_CONTROL \
            -e USE_VICON_CTRL=$USE_VICON_CTRL \
            -e START_CAMERA_SYNC=$START_CAMERA_SYNC \
            -e START_SWARM_LOOP=$START_SWARM_LOOP \
            -e USE_DJI_IMU=$USE_DJI_IMU \
            -e NODE_ID=$NODE_ID \
            -e PTGREY_ID=$PTGREY_ID \
            --name swarm \
            -d \
            -it ${DOCKER_IMAGE} \
            /bin/bash &> $LOG_PATH/log_docker.txt &
        echo "DOCKER RUN:"$!>>$PID_FILE




    echo "Enabling chicken blood mode"
    sudo /usr/sbin/nvpmodel -m0
    sudo /home/dji/jetson_clocks.sh

    sleep 5

    if [ $START_DJISDK -eq 1 ]
    then
        echo "dji_sdk start"
        tx2-docker exec swarm /ros_entrypoint.sh "./run_sdk.sh"
        sleep 5
    fi


    if [ $START_SWARM_LOOP -eq 1 ]
    then
        echo "start loopserver"
        tx2-docker exec -d swarm /ros_entrypoint.sh "./run_loopserver.sh"
        sleep 5
    fi


    if [ $START_CAMERA -eq 1 ]
    then
        echo "Trying to start camera driver"
        if [ $CAM_TYPE -eq 0 ]
        then
            echo "Will use pointgrey Camera"
            echo "Start Camera in unsync mode"
            roslaunch ptgrey_reader stereo.launch is_sync:=false  &> $LOG_PATH/log_camera.txt &
            PG_PID=$!
            echo "PTGREY_UNSYNC:"$! >> $PID_FILE
            if [ $START_CAMERA_SYNC -eq 1 ]
            then
                /bin/sleep 25
                rosservice call /dji_sdk_1/dji_sdk/set_hardsyc 20 0 &> $LOG_PATH/log_camera.txt &
                /bin/sleep 5
                sudo kill -- $PG_PID
                roslaunch ptgrey_reader stereo.launch &> $LOG_PATH/log_camera.txt &

                rosrun vins vins_node /home/dji/SwarmConfig/fisheye_ptgrey_n3/fisheye.yaml &> $LOG_PATH/log_vo.txt &
                echo "Start camera in sync mode"
                /bin/sleep 1.0
                #roslaunch swarm_vo_fuse stereo.launch is_sync:=true config_path:=$CONFIG_PATH/camera_config.yaml &>> $LOG_PATH/log_camera.txt &
                echo "PTGREY_SYNC:"$! >> $PID_FILE
            fi
        fi

        if [ $CAM_TYPE -eq 3 ]
        then
            echo "Will use realsense Camera"
            taskset -c 4-6  roslaunch realsense2_camera rs_camera.launch  &> $LOG_PATH/log_camera.txt &
            echo "REALSENSE:"$! >> $PID_FILE

            /bin/sleep 10
            echo "writing camera config"
            #/home/dji/SwarmAutoInstall/rs_write_cameraconfig.py
            #rosrun dynamic_reconfigure dynparam set /camera/stereo_module 'emitter_enabled' false
        fi
    fi



    if [ $START_VO_STUFF -eq 1 ]
    then
        /bin/sleep 10
        echo "Image ready start VO"
        tx2-docker exec -d swarm /ros_entrypoint.sh "./run_vo.sh"
    fi


    if [ $START_UWB_VICON -eq 1 ]
    then
        echo "Start UWB VO"
        tx2-docker exec -d swarm /ros_entrypoint.sh "./run_uwb_vicon.sh"
    fi

    if [ $START_UWB_COMM -eq 1 ]
    then
        echo "Start UWB COMM"
        roslaunch inf_uwb_ros uwb_node.launch &> $LOG_PATH/log_uwb_node.txt &
        echo "UWB NODE:"$! >> $PID_FILE
        tx2-docker exec -d swarm /ros_entrypoint.sh "./run_uwb_comm.sh"
    fi

    if [ $START_UWB_FUSE -eq 1 ]
    then
        echo "start ptgrey"
        tx2-docker exec -d swarm /ros_entrypoint.sh "./run_ptgrey.sh"
    fi
    if [ $START_UWB_FUSE -eq 1 ]
    then
        echo "Start swarm detector"
        tx2-docker exec -d swarm /ros_entrypoint.sh "./run_swarm_detection.sh"
    fi
    if [ $START_UWB_FUSE -eq 1 ]
    then
        echo "Start UWB fuse"
        tx2-docker exec -d swarm /ros_entrypoint.sh "./run_uwb_fuse.sh"
    fi


    if [ $START_CONTROL -eq 1 ]
    then
        echo "Start CONTROL"
        tx2-docker exec -d swarm /ros_entrypoint.sh "./run_control.sh"
    fi

    if [ $START_SWARM_LOOP -eq 1 ]
    then
        echo "Will start swarm loop"
        tx2-docker exec -d swarm /ros_entrypoint.sh "./run_swarmloop.sh"
    fi

    if [ $RECORD_BAG -eq 1 ]
    then
        rosbag record -o /ssd/bags/swarm_vicon_bags/swarm_log.bag /vins_estimator/imu_propagate /vins_estimator/odometry \
            /swarm_drones/swarm_drone_fused /swarm_drones/swarm_drone_fused_relative /swarm_drones/swarm_frame /swarm_drones/swarm_frame_predict /uwb_node/time_ref \
            /swarm_drones/swarm_drone_basecoor \
            /swarm_drones/est_drone_0_odom \
            /swarm_drones/est_drone_1_odom \
            /swarm_drones/est_drone_2_odom \
            /swarm_drones/est_drone_3_odom \
            /swarm_drones/est_drone_4_odom &
        echo "rosbag:"$! >> $PID_FILE

    fi
    if [ $RECORD_BAG -eq 2 ]
    then
        rosbag record -o /ssd/bags/swarm_vicon_bags/swarm_source_log.bag /swarm_drones/swarm_frame /swarm_drones/swarm_frame_predict /vins_estimator/imu_propagate /vins_estimator/odometry &
    fi

    if [ $RECORD_BAG -eq 3 ]
    then
        rosbag record -o /ssd/bags/swarm_loop.bag /dji_sdk_1/dji_sdk/imu /camera/infra1/image_rect_raw /camera/infra2/image_rect_raw /camera/depth/image_rect_raw /swarm_loop/remote_image_desc /uwb_node/time_ref /uwb_node/remote_nodes  /uwb_node/incoming_broadcast_data &
        echo "rosbag:"$! >> $PID_FILE
    fi


    if [ $RECORD_BAG -eq 4 ]
    then
        rosbag record -o /ssd/bags/swarm_loop /swarm_drones/swarm_frame /swarm_drones/swarm_frame_predict /swarm_loop/loop_connection
        echo "rosbag:"$! >> $PID_FILE
    fi

    echo "DOCKER START OK;"

    #wait $ROSCORE_PID

    #if [[ $? -gt 128 ]]
    #then
    #    kill $ROSCORE_PID
    #fi
fi
