#!/usr/bin/env bash
taskset -c 1-3 roslaunch swarm_yolo drone_detector.launch &> $LOG_PATH/log_swarm_detection.txt &
echo "SWARM_DETECT:"$! >> $PID_FILE

if [ $START_SWARM_LOOP -eq 1 ]
then
    taskset -c 1-3 roslaunch swarm_localization loop-5-drone.launch &> $LOG_PATH/log_swarm.txt &
else
    taskset -c 1-3 roslaunch swarm_localization local-5-drone.launch &> $LOG_PATH/log_swarm.txt &
fi
echo "SWARM_LOCAL:"$! >> $PID_FILE