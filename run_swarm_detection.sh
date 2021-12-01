#!/bin/bash
source /root/SwarmConfig/configs.sh
roslaunch swarm_detector detector.launch drone_id:=$DRONE_ID \
    external_nodelet:=true manager:=swarm_manager \
    drone_pose_network_model:=/root/swarm_ws/src/swarm_detector/config/drone_pose_v1.2_128x128_tx2_fp16.trt \
    cam_file:=/home/dji/SwarmConfig/fisheye_ptgrey_n3/up.yaml \
    cam_file_down:=/home/dji/SwarmConfig/fisheye_ptgrey_n3/down.yaml \
    &> $LOG_PATH/log_swarm_detection.txt &