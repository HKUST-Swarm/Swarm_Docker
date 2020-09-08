#!/usr/bin/env bash

source /root/SwarmConfig/configs.sh
roslaunch mocap_optitrack mocap_uwbclient.launch &> $LOG_PATH/log_uwb_mocap.txt &