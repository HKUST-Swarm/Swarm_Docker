#!/usr/bin/env bash

source /root/SwarmConfig/configs.sh
echo "docker start sdk"
nice --20 roslaunch dji_sdk sdk.launch &> $LOG_PATH/log_sdk.txt &
echo "DJISDK:"$! >> $PID_FILE
#sleep 5
