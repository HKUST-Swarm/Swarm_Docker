#!/usr/bin/env bash
CONFIG_PATH=/home/dji/SwarmConfig
source /home/dji/Swarm_Docker/start_configs.sh
source "/home/dji/swarm_ws/devel/setup.bash"
sudo rm -rf /root/.ros/log

echo "Enabling chicken blood mode"
sudo /usr/sbin/nvpmodel -m0
sudo /usr/bin/jetson_clocks
/home/dji/Swarm_Docker/run_roscore.sh

LOG_PATH=/home/dji/swarm_log/`date +%F_%T`

sudo mkdir -p $LOG_PATH
sudo chmod a+rw $LOG_PATH
sudo rm /home/dji/swarm_log_latest
ln -s $LOG_PATH /home/dji/swarm_log_latest
LOG_PATH=/home/dji/swarm_log_latest
sudo ln -s /root/.ros/log/latest $LOG_PATH


PID_FILE=/home/dji/swarm_log_latest/pids.txt
touch $PID_FILE

sleep 5
echo "START SDK" $START_DJISDK 

if [ $START_DJISDK -eq 1 ]
then
    echo "dji_sdk start"
    taskset -c 2 roslaunch dji_sdk sdk.launch  &> $LOG_PATH/log_dji_sdk.txt &
    echo "DJISDK:"$! >> $PID_FILE
    sleep 5

    if [ $START_CAMERA -eq 1 ]  && [ $CAM_TYPE -eq 0  ]
    then
        echo "Start trigger..."
        python /home/dji/Swarm_Docker/djisdk_sync_helper.py
    fi
fi

if [ $START_UWB_COMM -eq 1 ]
then
    echo "Start UWB COMM"
    roslaunch inf_uwb_ros uwb_node.launch &> $LOG_PATH/log_uwb_node.txt &
    echo "UWB NODE:"$! >> $PID_FILE
fi



if [ $START_CAMERA -eq 1 ]
then
    echo "Trying to start camera driver"
    if [ $CAM_TYPE -eq 0 ]
    then
        echo "Will use pointgrey Camera"
        roslaunch ptgrey_reader stereo.launch is_sync:=false &> $LOG_PATH/log_camera.txt &
        PG_PID=$!
        /bin/sleep 5
        sudo kill -- $PG_PID

        if [ $PTGREY_NODELET -eq 0 ]
        then
            echo "Start PointGrey in Sync Mode"
            roslaunch ptgrey_reader stereo.launch &> $LOG_PATH/log_camera.txt &
            echo "PTGREY:"$! >> $PID_FILE
        fi
    fi

    if [ $CAM_TYPE -eq 3 ]
    then
        echo "Will use realsense Camera"
        taskset -c 0,1  roslaunch realsense2_camera rs_camera.launch  &> $LOG_PATH/log_camera.txt &
        echo "REALSENSE:"$! >> $PID_FILE

        /bin/sleep 10
        echo "writing camera config"
    fi
fi


if [ $START_ROSBRIDGE -eq 1 ]
then
    roslaunch rosbridge_server rosbridge_websocket.launch &> $LOG_PATH/log_rosbridge.txt &
    echo "rosbridge:"$! >> $PID_FILE
fi

chmod -R a+rw $LOG_PATH
