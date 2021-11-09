#!/usr/bin/env bash
source /root/SwarmConfig/configs.sh

if [ $CAM_TYPE -eq 0 ]
then
    roslaunch swarm_loop nodelet-sfisheye.launch manager:=swarm_manager send_img:=$LOOP_SENDIMG self_id:=$DRONE_ID &> $LOG_PATH/log_swarm_loop.txt &
else
    roslaunch swarm_loop realsense.launch vins_config_path:=/home/dji/SwarmConfig/realsense/realsense.yaml \
        camera_config_path:=/home/dji/SwarmConfig/realsense/left.yaml \
        superpoint_model_path:=/root/swarm_ws/src/swarm_localization/swarm_loop/models/superpoint_v1_480x640_tx2_fp16.trt \
        netvlad_model_path:=/root/swarm_ws/src/swarm_localization/swarm_loop/models/mobilenetvlad_480x640_tx2_fp16.trt send_img:=$LOOP_SENDIMG self_id:=$DRONE_ID max_freq:=$LOOP_FREQ superpoint_max_num:=$LOOP_FEATURE_NUM &> $LOG_PATH/log_swarm_loop.txt &
fi
# echo "swarm_loop:"$! >> $PID_FILE

