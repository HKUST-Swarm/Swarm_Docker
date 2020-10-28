#!/usr/bin/env bash

source /root/SwarmConfig/configs.sh
echo "docker start sdk"
taskset -c 0-2 roslaunch dji_sdk sdk.launch &> $LOG_PATH/log_sdk.txt &
echo "DJISDK:"$! >> $PID_FILE
#sleep 5