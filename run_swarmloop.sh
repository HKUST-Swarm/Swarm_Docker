#!/usr/bin/env bash
taskset -c 1-3 roslaunch swarm_loop loop-only.launch &> $LOG_PATH/log_swarm_loop.txt &
echo "swarm_loop:"$! >> $PID_FILE