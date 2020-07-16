#!/usr/bin/env bash
taskset -c 1-3 roslaunch localization_proxy uwb_comm.launch &> $LOG_PATH/log_comm.txt &
echo "SWARM_UWB_COMM:"$! >> $PID_FILE