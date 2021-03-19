#!/bin/bash
source /root/SwarmConfig/configs.sh

taskset -c 0-2 roslaunch swarm_localization loop-5-drone.launch cgraph:=false &> $LOG_PATH/log_swarm.txt &
# echo "SWARM_LOCAL:"$! >> $PID_FILE
