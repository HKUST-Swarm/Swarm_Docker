#!/usr/bin/env bash
echo "Will start swarm loop"
taskset -c 1-3 roslaunch swarm_loop loop-server.launch &> $LOG_PATH/log_swarm_loop_server.txt &
echo "LOOPSERVER:"$! >> $PID_FILE
#sleep 5
#/bin/sleep 30