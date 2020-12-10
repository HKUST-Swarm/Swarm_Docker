#!/usr/bin/env bash


CONFIG_PATH=/home/dji/SwarmConfig
BAG_PID_FILE=/home/dji/swarm_log_latest/pid_bag.txt
LOG_PATH=/home/dji/swarm_log_latest
mkdir -p /ssd/bags/
RECORD=/opt/ros/melodic/lib/rosbag/record

source $CONFIG_PATH/configs.sh
source /home/dji/Swarm_Docker/start_configs.sh
source "/home/dji/swarm_ws/devel/setup.bash"

if [ $RECORD_BAG -eq 1 ]
then
    $RECORD -o /ssd/bags/swarm_vicon_bags/swarm_log.bag /vins_estimator/imu_propagate /vins_estimator/odometry \
        /swarm_drones/swarm_drone_fused /swarm_drones/swarm_drone_fused_relative /swarm_drones/swarm_frame /swarm_drones/swarm_frame_predict /uwb_node/time_ref \
        /swarm_drones/swarm_drone_basecoor \
        /swarm_loop/loop_connection \
        /swarm_drones/est_drone_0_odom \
        /swarm_drones/est_drone_1_odom \
        /swarm_drones/est_drone_2_odom \
        /swarm_drones/est_drone_3_odom \
        /swarm_drones/est_drone_4_odom \
        /SwarmNode0/pose \
        /SwarmNode1/pose \
        /SwarmNode2/pose \
        /SwarmNode3/pose \
        /SwarmNode4/pose \
        /SwarmNode5/pose &>$LOG_PATH/log_bag.txt &
    echo "rosbag:"$! > $BAG_PID_FILE
fi

if [ $RECORD_BAG -eq 2 ]
then
    $RECORD -o /ssd/bags/swarm_vicon_bags/swarm_source_log.bag /swarm_drones/swarm_frame /swarm_drones/swarm_frame_predict /vins_estimator/imu_propagate /vins_estimator/odometry &>$LOG_PATH/log_bag.txt &
    echo "rosbag:"$! > $BAG_PID_FILE
fi

if [ $RECORD_BAG -eq 3 ]
then
    $RECORD -o /ssd/bags/swarm_loop.bag /dji_sdk_1/dji_sdk/imu /camera/infra1/image_rect_raw /camera/infra2/image_rect_raw /camera/depth/image_rect_raw /swarm_loop/remote_image_desc /uwb_node/time_ref /uwb_node/remote_nodes  /uwb_node/incoming_broadcast_data &>$LOG_PATH/log_bag.txt &
    echo "rosbag:"$! > $BAG_PID_FILE
fi


if [ $RECORD_BAG -eq 4 ]
then
    echo "Record bag for swarm localization"
    $RECORD -o /ssd/bags/swarm_local.bag /swarm_drones/swarm_frame \
        /swarm_drones/swarm_frame_predict \
        /swarm_loop/loop_connection \
        /swarm_detection/swarm_detected_raw \
        /swarm_drones/swarm_drone_fused \
        /swarm_drones/swarm_drone_fused_relative \
        /swarm_drones/node_detected \
        /SwarmNode0/pose \
        /SwarmNode1/pose \
        /SwarmNode2/pose \
        /SwarmNode3/pose \
        /SwarmNode4/pose \
        /SwarmNode5/pose \
        /swarm_drones/est_drone_1_path \
        /swarm_drones/est_drone_2_path \
        /swarm_drones/est_drone_3_path \
        /swarm_drones/est_drone_4_path \
        /swarm_drones/est_drone_5_path \
        /swarm_loop/remote_frame_desc \
        /vins_estimator/odometry \
        /vins_estimator/keyframe_pose  &>$LOG_PATH/log_bag.txt &

    echo "rosbag:"$! > $BAG_PID_FILE
fi

if [ $RECORD_BAG -eq 5 ]
then
    echo "Record bag for swarm localization and swarm loop"
    $RECORD -o /ssd/bags/swarm_local.bag /swarm_drones/swarm_frame \
        /swarm_drones/swarm_frame_predict \
        /swarm_loop/loop_connection \
        /swarm_detection/swarm_detected_raw \
        /swarm_drones/swarm_drone_fused \
        /swarm_drones/swarm_drone_fused_relative \
        /swarm_drones/node_detected \
        /SwarmNode0/pose \
        /SwarmNode1/pose \
        /SwarmNode2/pose \
        /SwarmNode3/pose \
        /SwarmNode4/pose \
        /SwarmNode5/pose \
        /swarm_drones/est_drone_1_path \
        /swarm_drones/est_drone_2_path \
        /swarm_drones/est_drone_3_path \
        /swarm_drones/est_drone_4_path \
        /swarm_drones/est_drone_5_path \
        /swarm_loop/remote_frame_desc \
        /vins_estimator/flattened_gray \
        /vins_estimator/odometry \
        /vins_estimator/keyframe_pose &>$LOG_PATH/log_bag.txt &

    echo "rosbag:"$! > $BAG_PID_FILE
fi

echo "DOCKER START OK;"
chmod a+rw $BAG_PID_FILE
chown dji $LOG_PATH/log_bag.txt