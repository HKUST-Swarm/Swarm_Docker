#!/usr/bin/env bash

source /root/SwarmConfig/configs.sh
roslaunch localization_proxy uwb_comm.launch &> $LOG_PATH/log_comm.txt &
# echo "SWARM_UWB_COMM:"$! >> $PID_FILE
