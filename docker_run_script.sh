#!/bin/bash
CONFIG_PATH=/home/dji/SwarmConfig
source /root/Swarm_Docker/start_configs.sh
source "/root/swarm_ws/devel/setup.bash"

/root/Swarm_Docker/run_ssh.sh
if [ $START_VO -eq 1 ]
then
    /root/Swarm_Docker/run_nodelet_manager.sh
fi

if [ $START_UWB_COMM -eq 1 ] 
then
    /root/Swarm_Docker/run_uwb_comm.sh
fi

if [ $START_UWB_FUSE -eq 1 ]
then
    echo "Start UWB fuse"
    /root/Swarm_Docker/run_swarm_localization.sh
fi

if [ $ENABLE_LOOP -eq 1 ]
then
    echo "Will start swarm loop"
    /root/Swarm_Docker/run_swarmloop.sh
fi

if [ $START_UWB_FUSE -eq 1 ] && [ $ENABLE_DETECTION -eq 1 ]
then
    echo "Start swarm detector"
   /root/Swarm_Docker/run_swarm_detection.sh
fi

if [ $START_CONTROL -eq 1 ]
then
    echo "Start CONTROL (Drone cmd only)"
    /root/Swarm_Docker/run_control.sh
fi


if [ $START_VO -eq 1 ]
then
    if [ $PTGREY_NODELET -eq 0 ]
    then
        /bin/sleep 30
    fi
    echo "Image ready start VO"
    /root/Swarm_Docker/run_vo.sh
else
    if [ $PTGREY_NODELET -eq 1 ]
    then
        if [ $CAM_TYPE -eq 0 ]
        then
            echo "Not start vo, start nodelet manager for stereo-nodelet instead"
            rosrun nodelet nodelet manager __name:=swarm_manager --no-bond &> $LOG_PATH/log_camera.txt &
            roslaunch ptgrey_reader stereo-nodelet.launch manager:=swarm_manager is_sync:=true &> $LOG_PATH/log_camera.txt &
        fi
    fi
fi

if [ $START_PLAN -eq 1 ]
then

    /bin/sleep 30
    echo "Start FastPlanner"
    # roslaunch exploration_manager swarm_exploration_realworld.launch drone_id:=$DRONE_ID &> $LOG_PATH/log_fast_planner.txt &
    roslaunch plan_manage run_single_drone_realworld.launch drone_id:=$DRONE_ID &> $LOG_PATH/log_fast_planner.txt &

fi

if [ $USE_VICON_CTRL -eq 1 ]
then
    roslaunch pos_vel_mocap odometry_emulator.launch self_id:=$DRONE_ID &> $LOG_PATH/log_vicon.txt &
fi

if [ $USE_MOCAP -eq 1 ]
then
    roslaunch mocap_optitrack mocap.launch &> $LOG_PATH/log_vicon.txt &
fi

while [ true ]
do
    while true; do
        for N in {1..10}
        do
            ping 10.10.1.$N -c 3
        done
    done
done
