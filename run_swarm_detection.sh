#!/bin/bash
source /root/SwarmConfig/configs.sh

#taskset -c 0-2 roslaunch swarm_detector detector.launch device:=$PTGREY_ID &> $LOG_PATH/log_swarm_detection.txt &
# echo "SWARM_DETECT:"$! >> $PID_FILE
