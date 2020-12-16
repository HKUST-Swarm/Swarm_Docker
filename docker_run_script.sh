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

if [ $START_SWARM_LOOP -eq 1 ]
then
    echo "Will start swarm loop"
    /root/Swarm_Docker/run_swarmloop.sh
fi

if [ $START_PLAN -eq 1 ]
then
    echo "start planner"
    /root/Swarm_Docker/run_plan.sh
fi

if [ $START_UWB_FUSE -eq 1 ]
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
    /bin/sleep 30
    echo "Image ready start VO"
    /root/Swarm_Docker/run_vo.sh
fi

roslaunch mocap_optitrack mocap.launch &> $LOG_PATH/log_vicon.txt &

while [ true ]
do
    while true; do
        for N in {1..10}
        do
            ping 10.10.1.$N -c 3
        done
    done
done