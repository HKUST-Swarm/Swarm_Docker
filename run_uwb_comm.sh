#!/usr/bin/env bash

source /root/SwarmConfig/configs.sh

taskset -c 1-3 roslaunch localization_proxy uwb_comm.launch &> $LOG_PATH/log_comm.txt &
echo "SWARM_UWB_COMM:"$! >> $PID_FILE