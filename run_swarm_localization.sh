#!/bin/bash
source /root/SwarmConfig/configs.sh
roslaunch swarm_localization loop-5-drone.launch cgraph:=false \
    enable_distance:=$ENABLE_DISTANCE \
    enable_detection:=$ENABLE_DETECTION \
    enable_loop:=$ENABLE_LOOP &> $LOG_PATH/log_swarm.txt &
# echo "SWARM_LOCAL:"$! >> $PID_FILE
