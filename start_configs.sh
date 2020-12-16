source $CONFIG_PATH/configs.sh
source "/opt/ros/melodic/setup.bash"

export START_CAMERA=1
export START_UWB_COMM=0
export START_CONTROL=0
export START_CAMERA_SYNC=0
export START_UWB_FUSE=0
export START_DJISDK=1
export START_VO=0
export START_UWB_VICON=0
export USE_VICON_CTRL=0
export USE_DJI_IMU=0
export START_SWARM_LOOP=0
export ROS_MASTER_URI=http://localhost:11311

if [ $SWARM_START_MODE -ge 1 ]
then
    echo "Will start VO"
    START_VO=1
    START_CAMERA_SYNC=1
    if [ $CAM_TYPE -eq 3 ]
    then
        USE_DJI_IMU=1
    fi
fi

if [ $SWARM_START_MODE -ge 2 ]
then
    echo "Will start Control"
    START_CONTROL=1
fi

if [ $SWARM_START_MODE -ge 3 ]
then
    echo "Will start UWB COMM"
    START_UWB_COMM=1
fi

if [ $SWARM_START_MODE -ge 4 ]
then
    echo "Will start UWB FUSE"
    START_UWB_FUSE=1
fi

if [ $SWARM_START_MODE -ge 5 ]
then
    echo "Will start swarm loop"
    START_SWARM_LOOP=1
fi

if [ $START_CAMERA -eq 1 ]  && [ $CAM_TYPE -eq 0  ]  ||  [ $START_CONTROL -eq 1  ] || [ $USE_DJI_IMU -eq 1 ]
then
    export START_DJISDK=1
    echo "Using Ptgrey Camera, USE DJI IMU or using control, will boot dji sdk"
fi