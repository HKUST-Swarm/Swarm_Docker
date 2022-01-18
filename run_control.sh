#!/usr/bin/env bash
source /home/dji/SwarmConfig/configs.sh
PID_FILE=/home/dji/swarm_log_latest/pids.txt

echo "Start drone_commander"
nice --20 roslaunch drone_commander commander.launch &> $LOG_PATH/log_drone_commander.txt &
# echo "drone_commander:"$! >> $PID_FILE

echo "Start position ctrl"
nice --20 roslaunch drone_position_control pos_control.launch &> $LOG_PATH/log_drone_position_ctrl.txt &
# echo "drone_pos_ctrl:"$! >> $PID_FILE

echo "Start SwarmPilot"
roslaunch swarm_pilot swarm_pilot.launch drone_id:=$DRONE_ID &> $LOG_PATH/log_swarm_pilot.txt &
# echo "swarm_pilot:"$! >> $PID_FILE

if [ ! -z "$NET_STATS" ] && [ $NET_STATS -eq 1 ]
then
    rosrun swarm_loop swarm_loop_net_tester _self_id:=$DRONE_ID &> $LOG_PATH/log_network_stats.txt &
fi