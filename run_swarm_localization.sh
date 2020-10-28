#!/bin/bash
source /root/SwarmConfig/configs.sh

taskset -c 1-2 roslaunch swarm_localization loop-5-drone.launch &> $LOG_PATH/log_swarm.txt &
echo "SWARM_LOCAL:"$! >> $PID_FILE