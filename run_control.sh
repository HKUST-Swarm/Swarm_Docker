#!/usr/bin/env bash
source /home/dji/SwarmConfig/configs.sh
PID_FILE=/home/dji/swarm_log_latest/pids.txt

echo "Start drone_commander"
roslaunch drone_commander commander.launch &> $LOG_PATH/log_drone_commander.txt &
echo "drone_commander:"$! >> $PID_FILE
echo "Start position ctrl"
roslaunch drone_position_control pos_control.launch &> $LOG_PATH/log_drone_position_ctrl.txt &
echo "drone_pos_ctrl:"$! >> $PID_FILE
#rosrun traj_generator traj_test &> $LOG_PATH/log_traj.txt &
#echo "traj":$! >> $PID_FILE

echo "Start SwarmPilot"
rosrun swarm_pilot swarm_pilot_node &> $LOG_PATH/log_swarm_pilot.txt &
echo "swarm_pilot:"$! >> $PID_FILE
