#!/usr/bin/env bash
cd /root/catkin_ws/
source /root/catkin_ws/devel/setup.bash


#SDK
if [ $START_DJISDK -eq 1 ]
then
        roslaunch dji_sdk sdk.launch &> $LOG_PATH/log_sdk.txt & 
        echo "DJISDK:"$! >> $PID_FILE 
fi

#VO
if [ $START_VO -eq 1 ]
then
    sleep 10
    echo "Image ready start VO"
    if [ $CAM_TYPE -eq 0 ]
    then
        echo "No ptgrey VINS imple yet"
        # roslaunch vins_estimator dji_stereo.launch config_path:=$CONFIG_PATH/dji_stereo/dji_stereo.yaml &> $LOG_PATH/log_vo.txt &
    fi

    if [ $CAM_TYPE -eq 1 ]
    then
        taskset -c 1-4 rosrun vins vins_node /home/dji/SwarmConfig/mini_mynteye_stereo/mini_mynteye_stereo_imu.yaml &> $LOG_PATH/log_vo.txt &
        echo "VINS:"$! >> $PID_FILE
    fi

    if [ $CAM_TYPE -eq 3 ]
    then

        taskset -c 1-4 rosrun vins vins_node /home/dji/SwarmConfig/realsense/realsense_n3_unsync.yaml &> $LOG_PATH/log_vo.txt &
        echo "VINS:"$! >> $PID_FILE
    fi
fi

#UWB

if [ $START_UWB_VICON -eq 1 ]
then
    echo "Start UWB VO"
    roslaunch mocap_optitrack mocap_uwbclient.launch &> $LOG_PATH/log_uwb_mocap.txt 
fi

if [ $START_UWB_COMM -eq 1 ]
then
    roslaunch localization_proxy uwb_comm.launch &> $LOG_PATH/log_comm.txt &
    echo "SWARM_UWB_COMM:"$! >> $PID_FILE
fi

if [ $START_UWB_FUSE -eq 1 ]
then

    #roslaunch swarm_detection swarm_detect.launch &> $LOG_PATH/log_swarm_detection.txt &
    taskset -c 5-6 roslaunch swarm_yolo drone_detector.launch &> $LOG_PATH/log_swarm_detection.txt &
    echo "SWARM_DETECT:"$! >> $PID_FILE
    taskset -c 5-6 roslaunch swarm_localization local-5-drone.launch &> $LOG_PATH/log_swarm.txt &
    echo "SWARM_LOCAL:"$! >> $PID_FILE
fi

#control
if [ $START_CONTROL -eq 1 ]
then
    if [ $USE_VICON_CTRL -eq 1 ]
    then
        echo "Start drone_commander with VICON"
        roslaunch drone_commander commander.launch vo_topic:=/uwb_vicon_odom &> $LOG_PATH/log_drone_commander.txt &
        echo "drone_commander:"$! >> $PID_FILE
        echo "Start position ctrl with VICON"
        roslaunch drone_position_control pos_control_vicon.launch vo_topic:=/uwb_vicon_odom &> $LOG_PATH/log_drone_position_ctrl.txt &
        echo "drone_pos_ctrl:"$! >> $PID_FILE

    else
        echo "Start drone_commander"
        roslaunch drone_commander commander.launch &> $LOG_PATH/log_drone_commander.txt &
        echo "drone_commander:"$! >> $PID_FILE
        echo "Start position ctrl"
        roslaunch drone_position_control pos_control.launch &> $LOG_PATH/log_drone_position_ctrl.txt &
        echo "drone_pos_ctrl:"$! >> $PID_FILE
        rosrun traj_generator traj_test &> $LOG_PATH/log_traj.txt &
        echo "traj":$! >> $PID_FILE
    fi

    echo "Start SwarmPilot" 
    rosrun swarm_pilot swarm_pilot_node &> $LOG_PATH/log_swarm_pilot.txt &
    echo "swarm_pilot:"$! >> $PID_FILE
fi

while :; do
  sleep 300
done
