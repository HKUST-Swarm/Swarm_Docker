#!/usr/bin/env bash
if [ $USE_VICON_CTRL -eq 1 ]
then
    echo "Start drone_commander with VICON"
    taskset -c 1-3 roslaunch drone_commander commander.launch vo_topic:=/uwb_vicon_odom &> $LOG_PATH/log_drone_commander.txt &
    echo "drone_commander:"$! >> $PID_FILE
    echo "Start position ctrl with VICON"
    taskset -c 1-3 roslaunch drone_position_control pos_control_vicon.launch vo_topic:=/uwb_vicon_odom &> $LOG_PATH/log_drone_position_ctrl.txt &
    echo "drone_pos_ctrl:"$! >> $PID_FILE

else
    echo "Start drone_commander"
    taskset -c 1-3 roslaunch drone_commander commander.launch &> $LOG_PATH/log_drone_commander.txt &
    echo "drone_commander:"$! >> $PID_FILE
    echo "Start position ctrl"
    taskset -c 1-3 roslaunch drone_position_control pos_control.launch &> $LOG_PATH/log_drone_position_ctrl.txt &
    echo "drone_pos_ctrl:"$! >> $PID_FILE
    rosrun traj_generator traj_test &> $LOG_PATH/log_traj.txt &
    echo "traj":$! >> $PID_FILE
fi

echo "Start SwarmPilot"
rosrun swarm_pilot swarm_pilot_node &> $LOG_PATH/log_swarm_pilot.txt &
echo "swarm_pilot:"$! >> $PID_FILE
