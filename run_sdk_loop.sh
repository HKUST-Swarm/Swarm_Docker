#!/usr/bin/env bash
cd /root/catkin_ws/
source /root/driver_ws/devel/setup.bash
source /root/catkin_ws/devel/setup.bash
taskset -c 1-3 roslaunch dji_sdk sdk.launch
