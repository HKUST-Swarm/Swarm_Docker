#!/usr/bin/env bash
source /root/SwarmConfig/configs.sh

roslaunch swarm_loop loop-only-nodelet.launch manager:=swarm_manager send_img:=$LOOP_SENDIMG self_id:=$DRONE_ID &> $LOG_PATH/log_swarm_loop.txt &
# echo "swarm_loop:"$! >> $PID_FILE
