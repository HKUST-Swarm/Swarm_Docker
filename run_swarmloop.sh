#!/usr/bin/env bash
source /root/SwarmConfig/configs.sh

#roslaunch swarm_loop loop-only-nodelet.launch manager:=swarm_manager send_img:=$LOOP_SENDIMG self_id:=$DRONE_ID &> $LOG_PATH/log_swarm_loop.txt &
# echo "swarm_loop:"$! >> $PID_FILE

roslaunch swarm_loop loop-realsense.launch vins_config_path:=/home/dji/SwarmConfig/realsense/realsense.yaml \
    camera_config_path:=/home/dji/SwarmConfig/realsense/left.yaml \
    superpoint_model_path:=/root/swarm_ws/src/swarm_localization/swarm_loop/models/superpoint_v1_480x640_tx2_fp16.trt \
    netvlad_model_path:=/root/swarm_ws/src/swarm_localization/swarm_loop/models/mobilenetvlad_480x640_tx2_fp16.trt send_img:=$LOOP_SENDIMG self_id:=$DRONE_ID &> $LOG_PATH/log_swarm_loop.txt &
