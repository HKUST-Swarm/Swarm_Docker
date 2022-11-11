#!/bin/bash
source /root/SwarmConfig/configs.sh
# roslaunch swarm_localization loop-5-drone.launch cgraph:=false \
#     enable_distance:=$ENABLE_DISTANCE \
#     enable_detection:=$ENABLE_DETECTION \
#     enable_detection_depth:=$ENABLE_DETECTION_DEPTH \
#     enable_loop:=$ENABLE_LOOP &> $LOG_PATH/log_swarm.txt &
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/aarch64-linux-gnu/openblas-pthread/
roslaunch d2vins quadcam.launch superpoint_model_path:=/root/models/superpoint_v1_dyn_size.onnx \
    netvlad_model_path:=/root/models/mobilenetvlad_dyn_size.onnx \
    config:=/root/SwarmConfig/quadcam/quadcam_single.yaml \
    enable_loop:=$ENABLE_LOOP &> $LOG_PATH/log_d2slam.txt &
