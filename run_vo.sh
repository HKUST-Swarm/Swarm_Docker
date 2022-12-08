#!/usr/bin/env bash

source /root/SwarmConfig/configs.sh
export LD_PRELOAD=/usr/lib/gcc/aarch64-linux-gnu/7/libgomp.so

if [ $CAM_TYPE -eq 0 ]
then
    taskset -c 0,3,4,5 roslaunch vins fisheye.launch config_file:=/home/dji/SwarmConfig/fisheye_ptgrey_n3/fisheye_cuda.yaml &> $LOG_PATH/log_vo.txt &
    # echo "VINS:"$! >> $PID_FILE
    if [ $PTGREY_NODELET -eq 1 ]
    then
        /bin/sleep 3.0
        roslaunch ptgrey_reader stereo-nodelet.launch manager:=swarm_manager is_sync:=true &> $LOG_PATH/log_camera.txt &
    fi
fi

if [ $CAM_TYPE -eq 1 ]
then
    /bin/sleep 2.0
    if [ ! -z "$var" || $D2VINS_MULTI -eq 0 ]
    then
    echo "Lauching D2SLAM with single drone and realsense."
    roslaunch d2vins realsense.launch superpoint_model_path:=/root/models/superpoint_v1_dyn_size.onnx \
        netvlad_model_path:=/root/models/mobilenetvlad_dyn_size.onnx self_id:=$DRONE_ID \
        config:=/root/SwarmConfig/realsense_d435/d435_single.yaml enable_loop:=$ENABLE_LOOP enable_pgo:=$ENABLE_LOOP &> $LOG_PATH/log_vo.txt &
    else
    echo "Lauching D2SLAM with multi drone and realsense."
    roslaunch d2vins realsense.launch superpoint_model_path:=/root/models/superpoint_v1_dyn_size.onnx \
        netvlad_model_path:=/root/models/mobilenetvlad_dyn_size.onnx self_id:=$DRONE_ID \
        config:=/root/SwarmConfig/realsense_d435/d435_multi.yaml enable_loop:=$ENABLE_LOOP enable_pgo:=$ENABLE_LOOP &> $LOG_PATH/log_vo.txt &
    fi
    if [ $PTGREY_NODELET -eq 1 ]
    then
        /bin/sleep 3.0
	    echo "running realsense in docker"
        roslaunch realsense2_camera rs_camera.launch external_manager:=true manager:=/swarm_manager &> $LOG_PATH/log_camera.txt &
    fi
fi

# if [ $FC_TYPE -eq 1 ] 
# then
#     roslaunch px4_realsense_bridge bridge.launch  &> $LOG_PATH/vo_bridge.txt &
# fi