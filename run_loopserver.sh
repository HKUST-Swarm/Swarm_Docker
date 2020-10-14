#!/usr/bin/env bash
source /root/SwarmConfig/configs.sh
echo "Will start swarm loop"
taskset -c 1-3 roslaunch swarm_loop hfnet_server.launch memory_limit:=512 &> $LOG_PATH/log_hfnet_server.txt &
echo "LOOPSERVER:"$! >> $PID_FILE