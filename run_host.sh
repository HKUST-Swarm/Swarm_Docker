#!/usr/bin/env bash
CONFIG_PATH=/home/dji/SwarmConfig
source $CONFIG_PATH/configs.sh

echo "Enabling chicken blood mode"
sudo /usr/sbin/nvpmodel -m0
sudo /usr/bin/jetson_clocks
/home/dji/Swarm_Docker/run_roscore.sh

echo "Sourcing host machine..."
source /opt/ros/melodic/setup.bash
source /home/dji/swarm_ws/devel/setup.bash

export ROS_MASTER_URI=http://localhost:11311

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

if [ $START_DJISDK -eq 1 ]
then
    echo "dji_sdk start"
    taskset -c 2 roslaunch dji_sdk sdk.launch  &> $LOG_PATH/log_dji_sdk.txt &
    echo "DJISDK:"$! >> $PID_FILE
    sleep 5

    if [ $START_CAMERA -eq 1 ]  && [ $CAM_TYPE -eq 0  ]
    then
        python /home/dji/Swarm_Docker/djisdk_sync_helper.py
    fi
fi


if [ $START_UWB_VICON -eq 1 ]
then
    echo "START INF UWB ROS"
    taskset -c 1 roslaunch inf_uwb_ros uwb.launch &> $LOG_PATH/log_uwb.txt &
    echo "SWARM_INF_UWB:"$! >> $PID_FILE

    echo "Start UWB VO"
    nvidia-docker exec -d swarm /ros_entrypoint.sh "/root/Swarm_Docker/run_uwb_vicon.sh"
fi

if [ $START_UWB_COMM -eq 1 ]
then
    echo "Start UWB COMM"
    taskset -c 1 roslaunch inf_uwb_ros uwb_node.launch &> $LOG_PATH/log_uwb_node.txt &
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



if [ $RECORD_BAG -eq 1 ]
then
    rosbag record -o /ssd/bags/swarm_vicon_bags/swarm_log.bag /vins_estimator/imu_propagate /vins_estimator/odometry \
        /swarm_drones/swarm_drone_fused /swarm_drones/swarm_drone_fused_relative /swarm_drones/swarm_frame /swarm_drones/swarm_frame_predict /uwb_node/time_ref \
        /swarm_drones/swarm_drone_basecoor \
        /swarm_drones/est_drone_0_odom \
        /swarm_drones/est_drone_1_odom \
        /swarm_drones/est_drone_2_odom \
        /swarm_drones/est_drone_3_odom \
        /swarm_drones/est_drone_4_odom &
    echo "rosbag:"$! >> $PID_FILE

fi
if [ $RECORD_BAG -eq 2 ]
then
    rosbag record -o /ssd/bags/swarm_vicon_bags/swarm_source_log.bag /swarm_drones/swarm_frame /swarm_drones/swarm_frame_predict /vins_estimator/imu_propagate /vins_estimator/odometry &
fi

if [ $RECORD_BAG -eq 3 ]
then
    rosbag record -o /ssd/bags/swarm_loop.bag /dji_sdk_1/dji_sdk/imu /camera/infra1/image_rect_raw /camera/infra2/image_rect_raw /camera/depth/image_rect_raw /swarm_loop/remote_image_desc /uwb_node/time_ref /uwb_node/remote_nodes  /uwb_node/incoming_broadcast_data &
    echo "rosbag:"$! >> $PID_FILE
fi


if [ $RECORD_BAG -eq 4 ]
then
    rosbag record -o /ssd/bags/swarm_loop /swarm_drones/swarm_frame /swarm_drones/swarm_frame_predict /swarm_loop/loop_connection
    echo "rosbag:"$! >> $PID_FILE
fi

echo "DOCKER START OK;"
