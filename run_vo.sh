#!/usr/bin/env bash

source /root/SwarmConfig/configs.sh
export LD_PRELOAD=/usr/lib/gcc/aarch64-linux-gnu/7/libgomp.so

if [ $CAM_TYPE -eq 0 ]
then
    taskset -c 4-6 roslaunch vins fisheye.launch config_file:=/home/dji/SwarmConfig/fisheye_ptgrey_n3/fisheye_cuda.yaml &> $LOG_PATH/log_vo.txt &
    echo "VINS:"$! >> $PID_FILE
    /bin/sleep 1.0
fi

if [ $CAM_TYPE -eq 1 ]
then
    taskset -c 5-6 rosrun vins vins_node /home/dji/SwarmConfig/mini_mynteye_stereo/mini_mynteye_stereo_imu.yaml &> $LOG_PATH/log_vo.txt &
    echo "VINS:"$! >> $PID_FILE
fi

if [ $CAM_TYPE -eq 3 ]
then
    #taskset -c 4-6 roslaunch vins nodelet_realsense_full.launch config_file:=/home/dji/SwarmConfig/realsense/realsense_n3_unsync.yaml &> $LOG_PATH/log_vo.txt &
    rosrun vins vins_node /home/dji/SwarmConfig/realsense/realsense_n3_unsync.yaml &> $LOG_PATH/log_vo.txt &
    echo "VINS:"$! >> $PID_FILE
    sleep 5
fi
