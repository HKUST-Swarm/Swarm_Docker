# Swarm_Docker
UAV Swarm --2019-20 FYP
### For manifold 2g 
Packages required:
- opencv 3.4.1
- cuda-9.0 library
- TX2 giving docker access to gpu[tx2-docker wrapper script under /bin]
- cv-bridge package with pointing to unique opencv 3.4.1
Docker image is under Docker Hub, the repo is xyaoab/swarmuav:vins_v1
#### 12/2 Updates
To start a Docker container,
```
tx2-docker run -it xyaoab/swarmuav:vins_v1 /bin/bash
```
Assume roscore, camera drivers are running on host machines with N3 IMU on 
In docker,
```
rosrun vins vins_node /home/dji/SwarmConfig/realsense/realsense_n3_unsync.yaml 
```
On host machine, 
```
roslaunch vins vins_rviz.launch
```
---
##### 12/6 Updates
Launch system from shell script:

- host_cmd.sh inside docker: /root/catkin_ws
- run_docker.sh inside host machine
Logs: 
1. pass variables using -v 
2. pass ttyusb in /dev using -d
3. cmake swarm_w spackages  (remove swarm_detection[aruco]; cp usr/share/opencv; catkin build can't link header file[solved by catkin_make instead)


To do list: 
- ~pass UART as device~
- ~contain DJI_SDK & UWB inside the docker~
- ~GCC V7 updates~
- move realsense drive and ros wrapper inside docker 
- test on uav 
- tensoflow & pytorch config
- ~add docker run without shellscript~
- checking binary difference and patch updates
