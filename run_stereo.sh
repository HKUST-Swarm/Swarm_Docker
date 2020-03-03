#!/usr/bin/env bash
echo "Start Camera in unsync mode"
roslaunch ptgrey_reader stereo.launch is_sync:=false &> $LOG_PATH/log_camera.txt &
PG_PID=$!
echo "PTGREY_UNSYNC:"$! >> $PID_FILE
if [ $START_CAMERA_SYNC -eq 1 ]
then
    /bin/sleep 25
    rosservice call /dji_sdk_1/dji_sdk/set_hardsyc 20 0 &> $LOG_PATH/log_camera.txt &
    /bin/sleep 5
    sudo kill -- $PG_PID
    roslaunch ptgrey_reader stereo.launch &> $LOG_PATH/log_camera.txt &

    #rosrun vins vins_node /home/dji/SwarmConfig/fisheye_ptgrey_n3/fisheye.yaml &> $LOG_PATH/log_vo.txt &
    echo "Start camera in sync mode"
    #/bin/sleep 1.0
    echo "PTGREY_SYNC:"$! >> $PID_FILE
fi
