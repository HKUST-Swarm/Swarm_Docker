#!/bin/bash
if [ $START_SWARM_LOOP -eq 1 ]
then
    taskset -c 1-3 roslaunch swarm_localization loop-5-drone.launch &> $LOG_PATH/log_swarm.txt &
else
    taskset -c 1-3 roslaunch swarm_localization local-5-drone.launch &> $LOG_PATH/log_swarm.txt &
fi
echo "SWARM_LOCAL:"$! >> $PID_FILE