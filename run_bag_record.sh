#!/usr/bin/env bash
CONFIG_PATH=/home/dji/SwarmConfig
source $CONFIG_PATH/configs.sh
PID_FILE=/home/dji/swarm_log_latest/pids.txt

mkdir -p /ssd/bags/

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
    echo "Record bag for swarm localization"
    rosbag record -o /ssd/bags/swarm_local.bag /swarm_drones/swarm_frame /swarm_drones/swarm_frame_predict /swarm_loop/loop_connection &
    echo "rosbag:"$! >> $PID_FILE
fi

echo "DOCKER START OK;"
