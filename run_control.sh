#!/usr/bin/env bash
source /home/dji/SwarmConfig/configs.sh
PID_FILE=/home/dji/swarm_log_latest/pids.txt

if [ $START_FC_SDK -eq 0 ]
then
    echo "Start drone_commander"
    nice --20 roslaunch drone_commander commander.launch &> $LOG_PATH/log_drone_commander.txt &
    echo "Start position ctrl"
    nice --20 roslaunch drone_position_control pos_control.launch &> $LOG_PATH/log_drone_position_ctrl.txt &
else
    echo "Start drone_commander for PX4"
    nice --20 roslaunch drone_commander commander-px4.launch vo_topic:=/d2vins/imu_propagation &> $LOG_PATH/log_drone_commander.txt &
fi

echo "Start SwarmPilot"
roslaunch swarm_pilot swarm_pilot.launch drone_id:=$DRONE_ID enable_planner:=START_PLAN &> $LOG_PATH/log_swarm_pilot.txt &
