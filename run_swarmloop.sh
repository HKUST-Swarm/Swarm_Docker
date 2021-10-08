#!/usr/bin/env bash
source /root/SwarmConfig/configs.sh

if [ $CAM_TYPE -eq 0 ]
then
    roslaunch swarm_loop nodelet-sfisheye.launch manager:=swarm_manager send_img:=$LOOP_SENDIMG self_id:=$DRONE_ID &> $LOG_PATH/log_swarm_loop.txt &
else
    roslaunch swarm_loop realsense.launch manager:=swarm_manager send_img:=$LOOP_SENDIMG self_id:=$DRONE_ID &> $LOG_PATH/log_swarm_loop.txt &
fi
# echo "swarm_loop:"$! >> $PID_FILE
