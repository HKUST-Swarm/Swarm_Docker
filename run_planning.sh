#!/bin/bash
source /root/SwarmConfig/configs.sh
/bin/sleep 30
echo "Start FastPlanner"

#roslaunch exploration_manager swarm_exploration_realworld.launch drone_id:=$DRONE_ID &> $LOG_PATH/log_fast_planner.txt &
roslaunch plan_manage run_single_drone_realworld.launch drone_id:=$DRONE_ID &> $LOG_PATH/log_fast_planner.txt &