#!/usr/bin/env bash

source /root/SwarmConfig/configs.sh
export LD_PRELOAD=/usr/lib/gcc/aarch64-linux-gnu/7/libgomp.so

if [ $CAM_TYPE -eq 0 ]
then
    taskset -c 0,3,4,5 roslaunch vins fisheye.launch config_file:=/home/dji/SwarmConfig/fisheye_ptgrey_n3/fisheye_cuda.yaml &> $LOG_PATH/log_vo.txt &
    # echo "VINS:"$! >> $PID_FILE
    if [ $PTGREY_NODELET -eq 1 ]
    then
        /bin/sleep 3.0
        roslaunch ptgrey_reader stereo-nodelet.launch manager:=swarm_manager is_sync:=true &> $LOG_PATH/log_camera.txt &
    fi
fi

if [ $CAM_TYPE -eq 1 ]
then
    if [ $PTGREY_NODELET -eq 1 ]
    then
        /bin/sleep 3.0
	    echo "running realsense in docker"
        roslaunch realsense2_camera rs_camera.launch external_manager:=true manager:=/swarm_manager \
            infra_fps:=$INFRA_FPS  depth_fps:=$DEPTH_FPS \
            enable_color:=$ENABLE_COLOR color_fps:=$COLOR_FPS \
            &> $LOG_PATH/log_camera.txt &
    fi
    roslaunch vins pinhole.launch manager:=/swarm_manager config_file:=/home/dji/SwarmConfig/realsense/realsense.yaml &> $LOG_PATH/log_vo.txt &
    #rosrun vins vins_node /home/dji/SwarmConfig/realsense/realsense.yaml &> $LOG_PATH/log_vo.txt &
    sleep 5
fi
