#!/usr/bin/env bash
trap : SIGTERM SIGINT

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"
DOCKER_IMAGE=192.168.1.204:5000/swarm_push:latest
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
            --privileged -v /dev/ttyPTGREY:/dev/ttyPREY \
            -v /dev/ttyUSB0:/dev/ttyUSB0 \
            -v /home/dji/.ssh:/root/.ssh \
            --rm \
            -it ${DOCKER_LOCAL_IMAGE} \
            /bin/bash

elif [ $RUN -eq 1 ]; then

    echo "Sourceing..."
    source /opt/ros/kinetic/setup.bash
    source /home/dji/swarm_ws/devel/setup.bash

    export ROS_MASTER_URI=http://localhost:11311


    LOG_PATH=/home/dji/swarm_log/`date +%F_%T`
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

        PID_FILE=/home/dji/swarm_log_lastest/pids.txt
        touch $PID_FILE
        echo "Start ros core"
        roscore &> $LOG_PATH/log_roscore.txt &
        echo "roscore:"$! >> $PID_FILE
        #using roscore pid to track
        ROSCORE_PID=$!
        #Sleep 5 wait for core
        sleep 5

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

        if [ $SWARM_START_MODE -eq 5 ]
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

    if [ $CONFIG_NETWORK -eq 1 ]; then
        /home/dji/SwarmAutoInstall/setup_adhoc.sh $NODE_ID &> $LOG_PATH/log_network.txt &
        echo "Wait 10 for network setup"
        sleep 10
    fi


    echo "Enabling chicken blood mode"
    sudo /usr/sbin/nvpmodel -m0
    sudo /home/dji/jetson_clocks.sh



    if [ $START_CAMERA -eq 1 ]
    then
        echo "Trying to start camera driver"
        if [ $CAM_TYPE -eq 0 ]
        then
            echo "Will use pointgrey Camera"
            echo "Start Camera in unsync mode"
            #roslaunch swarm_vo_fuse stereo.launch is_sync:=false config_path:=$CONFIG_PATH/camera_config.yaml &> $LOG_PATH/log_camera.txt &
            PG_PID=$!
            echo "PTGREY_UNSYNC:"$! >> $PID_FILE
            if [ $START_CAMERA_SYNC -eq 1 ]
            then
                sleep 5
                sudo kill -- $PG_PID
                echo "Start camera in sync mode"
                sleep 1.0
                #roslaunch swarm_vo_fuse stereo.launch is_sync:=true config_path:=$CONFIG_PATH/camera_config.yaml &>> $LOG_PATH/log_camera.txt &
                echo "PTGREY_SYNC:"$! >> $PID_FILE
            fi
        fi

        if [ $CAM_TYPE -eq 1 ]
        then
            echo "Will use MYNT Camera"
            source /home/dji/source/MYNT-EYE-S-SDK/wrappers/ros/devel/setup.bash
            roslaunch mynt_eye_ros_wrapper mynteye.launch request_index:=1 &> $LOG_PATH/log_camera.txt &
            echo "MYNT_CAMERA:"$! >> $PID_FILE
            sleep 2
        fi

        if [ $CAM_TYPE -eq 2 ]
        then
            echo "Will use bluefox Camera"
            roslaunch bluefox2 single_node.launch device:=$CAMERA_ID &> $LOG_PATH/log_camera.txt &
            echo "BLUEFOX:"$! >> $PID_FILE
        fi

        if [ $CAM_TYPE -eq 3 ]
        then
            echo "Will use realsense Camera"
            roslaunch realsense2_camera rs_camera.launch  &> $LOG_PATH/log_camera.txt &
            echo "writing camera config"
            #/home/dji/SwarmAutoInstall/rs_write_cameraconfig.py
            rosrun dynamic_reconfigure dynparam set /camera/stereo_module 'emitter_enabled' false
            echo "REALSENSE:"$! >> $PID_FILE
        fi
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



    tx2-docker run \
                -v /home/dji/swarm_log:/home/dji/swarm_log \
                -v $PID_FILE:$PID_FILE \
                --rm \
                -e PID_FILE=$PID_FILE \
                -e LOG_PATH=$LOG_PATH \
                -e START_DJISDK=$START_DJISDK \
                -e START_VO_STUFF=$START_VO_STUFF \
                -e CAM_TYPE=$CAM_TYPE \
                -e START_UWB_VICON=$START_UWB_VICON \
                -e START_UWB_COMM=$START_UWB_COMM \
                -e START_UWB_FUSE=$START_UWB_FUSE \
                -e START_CONTROL=$START_CONTROL \
                -e USE_VICON_CTRL=$USE_VICON_CTRL \
                -it ${DOCKER_IMAGE} \
                /bin/bash /root/catkin_ws/host_cmd.sh

    wait $ROSCORE_PID

    if [[ $? -gt 128 ]]
    then
    kill $ROSCORE_PID
    fi
fi
