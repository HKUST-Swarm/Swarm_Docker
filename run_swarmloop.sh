#!/usr/bin/env bash
source /root/SwarmConfig/configs.sh

taskset -c 1-2 roslaunch swarm_loop loop-only.launch manager:=loop_manager send_img:=$LOOP_SENDIMG self_id:=$DRONE_ID &> $LOG_PATH/log_swarm_loop.txt &
echo "swarm_loop:"$! >> $PID_FILE