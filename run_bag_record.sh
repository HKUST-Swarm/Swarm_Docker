#!/usr/bin/env bash


CONFIG_PATH=/home/dji/SwarmConfig
BAG_PID_FILE=/home/dji/swarm_log_latest/pid_bag.txt
LOG_PATH=/home/dji/swarm_log_latest
mkdir -p /ssd/bags/
RECORD=/opt/ros/melodic/lib/rosbag/record
ARGS="--buffsize 4096"

source $CONFIG_PATH/configs.sh
source /home/dji/Swarm_Docker/start_configs.sh
source "/home/dji/swarm_ws/devel/setup.bash"

if [ $RECORD_BAG -eq 0 ]
then
    echo "Record raw data for swarm localization"
    $RECORD $ARGS -o /ssd/bags/swarm_local_raw.bag \
        /SwarmNode0/pose \
        /SwarmNode1/pose \
        /SwarmNode2/pose \
        /SwarmNode3/pose \
        /SwarmNode4/pose \
        /SwarmNode5/pose \
	/dji_sdk_1/dji_sdk/imu \
	/uwb_node/remote_nodes \
	/uwb_node/time_ref \
        /uwb_node/incoming_broadcast_data \
	/stereo/left/image_raw \
	/stereo/right/image_raw \
	/camera/infra1/image_rect_raw \
	/camera/infra2/image_rect_raw \
	/camera/infra1/camera_info \
	/camera/infra2/camera_info \
	/camera/depth/image_rect_raw \
	/camera/depth/camera_info \
    /camera/color/camera_info \
    /camera/color/image_raw \
	&>$LOG_PATH/log_bag.txt &

    echo "rosbag:"$! > $BAG_PID_FILE

fi


if [ $RECORD_BAG -eq 1 ]
then
    echo "Record raw data for swarm localization"
    $RECORD $ARGS -o /ssd/bags/swarm_local_raw.bag \
        /SwarmNode0/pose \
        /SwarmNode1/pose \
        /SwarmNode2/pose \
        /SwarmNode3/pose \
        /SwarmNode4/pose \
        /SwarmNode5/pose \
	/dji_sdk_1/dji_sdk/imu \
	/uwb_node/remote_nodes \
	/uwb_node/time_ref \
    /uwb_node/incoming_broadcast_data \
	/stereo/left/image_compressed \
	/stereo/right/image_compressed \
	/camera/infra1/image_rect_raw/compressed \
	/camera/infra2/image_rect_raw/compressed \
	/camera/infra1/camera_info \
	/camera/infra2/camera_info \
    /camera/color/camera_info \
    /camera/color/image_raw/compressed \
	/camera/depth/image_rect_raw \
    /swarm_drones/swarm_network_status \
    /swarm_loop/drone_network_status \
	/camera/depth/camera_info \
	&>$LOG_PATH/log_bag.txt &

    echo "rosbag:"$! > $BAG_PID_FILE

fi

if [ $RECORD_BAG -eq 2 ]
then
    echo "Record bag for swarm localization"
    $RECORD $ARGS -o /ssd/bags/swarm_local.bag /swarm_drones/swarm_frame \
        /swarm_drones/swarm_frame_predict \
        /swarm_loop/loop_connection \
        /swarm_detection/swarm_detected_raw \
        /swarm_drones/swarm_drone_fused \
        /swarm_drones/swarm_drone_fused_relative \
        /swarm_drones/swarm_drone_basecoor \
        /swarm_drones/node_detected \
        /swarm_drones/node_detected_6d \
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
        /swarm_loop/keyframe \
        /vins_estimator/odometry \
        /planning/bspline \
        /planning/goal \
        /planning/new \
        /planning/pos_cmd \
        /planning/position_cmd_vis \
        /planning/replan \
        /planning/swarm_traj \
        /planning/swarm_traj_recv \
        /planning/swarm_traj_send \
        /vins_estimator/keyframe_pose \
        /sdf_map/occupancy_all_$DRONE_ID \
        /sdf_map/occupancy_local_$DRONE_ID \
        /planning_vis/trajectory_$DRONE_ID \
        /planning/travel_traj_$DRONE_ID \
        /planning_vis/frontier_$DRONE_ID \
        /planning/position_cmd_vis_$DRONE_ID \
        /planning_vis/viewpoints_$DRONE_ID \
        /planning/pos_cmd_$DRONE_ID \
        &>$LOG_PATH/log_bag.txt &

    echo "rosbag:"$! > $BAG_PID_FILE
fi

if [ $RECORD_BAG -eq 5 ]
then
    echo "Record bag for swarm localization, raw data for swarm loop and swarm detection"
    $RECORD $ARGS -o /ssd/bags/swarm_local.bag /swarm_drones/swarm_frame \
        /swarm_drones/swarm_frame_predict \
        /swarm_loop/loop_connection \
	/swarm_loop/keyframe \
        /swarm_drones/swarm_drone_fused \
        /swarm_drones/swarm_drone_fused_relative \
        /swarm_drones/swarm_drone_basecoor \
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
        /vins_estimator/imu_propagate \
        /vins_estimator/flattened_raw \
        /planning/bspline \
        /planning/goal \
        /planning/new \
        /planning/pos_cmd \
        /planning/position_cmd_vis \
        /planning/replan \
        /planning/swarm_traj \
        /planning/swarm_traj_recv \
        /planning/swarm_traj_send \
        /planning/travel_traj \
	    /uwb_node/remote_nodes \
	    /uwb_node/time_ref \
        /uwb_node/incoming_broadcast_data \
        /vins_estimator/keyframe_pose &>$LOG_PATH/log_bag.txt &

    echo "rosbag:"$! > $BAG_PID_FILE
fi

echo "DOCKER START OK;"
chmod a+rw $BAG_PID_FILE
chown dji $LOG_PATH/log_bag.txt
