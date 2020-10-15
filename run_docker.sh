#!/usr/bin/env bash
trap : SIGTERM SIGINT

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

source /home/dji/Swarm_Docker/image_config.sh

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
        u) docker push xuhao1/swarm2020 ${DOCKER_IMAGE}
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
            -it ${DOCKER_IMAGE} \
            /bin/zsh

elif [ $RUN -eq 1 ]; then

    echo "Sourcing host machine..."
    source /opt/ros/melodic/setup.bash
    source /home/dji/swarm_ws/devel/setup.bash

    export ROS_MASTER_URI=http://localhost:11311

    CONFIG_PATH=/home/dji/SwarmConfig
    source $CONFIG_PATH/configs.sh

    LOG_PATH=/home/dji/swarm_log/`date +%F_%T`

    if [ "$#" -ge 2 ]; then
        export SWARM_START_MODE=$2
    fi

    echo "Start swarm with MODE" $2

    if [ $SWARM_START_MODE -ge 0 ]
    then
        sudo mkdir -p $LOG_PATH
        sudo chmod a+rw $LOG_PATH
        sudo rm /home/dji/swarm_log_latest
        ln -s $LOG_PATH /home/dji/swarm_log_latest
        LOG_PATH=/home/dji/swarm_log_latest
        sudo ln -s /root/.ros/log/latest $LOG_PATH

        #/home/dji/Swarm_Docker/pull_docker.sh >> /home/dji/log.txt 2>&1
        #echo "Pull docker start"

        PID_FILE=/home/dji/swarm_log_latest/pids.txt
        touch $PID_FILE
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

    echo "Start NVIDIA DOCKER"
    nvidia-docker run \
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
            -d \
            --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
            ${DOCKER_IMAGE} \
            /run_roscore.sh #&> $LOG_PATH/log_docker.txt &
        echo "DOCKER RUN:"$!>>$PID_FILE

    sleep 5
    if [ $START_ROSBRIDGE -eq 1 ]
    then
        roslaunch rosbridge_server rosbridge_websocket.launch &> $LOG_PATH/log_rosbridge.txt &
        echo "rosbridge:"$! >> $PID_FILE
    fi

    echo "Enabling chicken blood mode"
    sudo /usr/sbin/nvpmodel -m0
    sudo /usr/bin/jetson_clocks
    nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_ssh.sh"

    sleep 5

    if [ $START_DJISDK -eq 1 ]
    then
        echo "dji_sdk start"
        roslaunch dji_sdk sdk.launch  &> $LOG_PATH/log_dji_sdk.txt &
        echo "DJISDK:"$! >> $PID_FILE
        sleep 5

        if [ $START_CAMERA -eq 1 ]  && [ $CAM_TYPE -eq 0  ]
        then
            python /home/dji/Swarm_Docker/djisdk_sync_helper.py
        fi
    fi


    if [ $START_SWARM_LOOP -eq 1 ]
    then
        echo "start loopserver"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_loopserver.sh"
    fi

    if [ $START_PLAN -eq 1 ]
    then
        echo "start planner"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_plan.sh"
    fi

    if [ $START_CAMERA -eq 1 ]
    then
        echo "Trying to start camera driver"
        if [ $CAM_TYPE -eq 0 ]
        then
            echo "Will use pointgrey Camera"
            roslaunch ptgrey_reader stereo.launch is_sync:=false &> $LOG_PATH/log_camera.txt &
            PG_PID=$!
            /bin/sleep 5
            sudo kill -- $PG_PID

            echo "Start PointGrey in Sync Mode"
            roslaunch ptgrey_reader stereo.launch &> $LOG_PATH/log_camera.txt &
            echo "PTGREY:"$! >> $PID_FILE
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

    if [ $START_SWARM_LOOP -eq 1 ]
    then
        echo "Wait for loop server bootup, this really take a long time"
        python /home/dji/Swarm_Docker/wait_for_loop_server.py
    fi

    if [ $START_VO -eq 1 ]
    then
        /bin/sleep 10
        echo "Image ready start VO"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_vo.sh"
    fi


    if [ $START_UWB_VICON -eq 1 ]
    then
        echo "START INF UWB ROS"
        taskset -c 1-3 roslaunch inf_uwb_ros uwb.launch &> $LOG_PATH/log_uwb.txt &
        echo "SWARM_INF_UWB:"$! >> $PID_FILE

        echo "Start UWB VO"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_uwb_vicon.sh"
    fi

    if [ $START_UWB_COMM -eq 1 ]
    then
        echo "Start UWB COMM"
        roslaunch inf_uwb_ros uwb_node.launch &> $LOG_PATH/log_uwb_node.txt &
        echo "UWB NODE:"$! >> $PID_FILE
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_uwb_comm.sh"
    fi

    if [ $START_UWB_FUSE -eq 1 ]
    then
        echo "Start swarm detector"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_swarm_detection.sh"
    fi
    if [ $START_UWB_FUSE -eq 1 ]
    then
        echo "Start UWB fuse"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_uwb_fuse.sh"
    fi


    if [ $START_CONTROL -eq 1 ]
    then
	echo "Start CONTROL (Drone cmd only)"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_control.sh"
        #taskset -c 1-3 roslaunch drone_position_control pos_control.launch &> $LOG_PATH/log_drone_position_ctrl.txt &
        #echo "drone_pos_ctrl:"$! >> $PID_FILE

    fi

    if [ $START_SWARM_LOOP -eq 1 ]
    then
        echo "Will start swarm loop"
        nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_swarmloop.sh"
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
fi
