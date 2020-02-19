# Swarm_Docker
UAV Swarm --2019-20 FYP

Docker image is under Docker Hub  and under Docker registry with repository name a [xyaoab/swarmuav:latest](https://hub.docker.com/repository/registry-1.docker.io/xyaoab/swarmuav/tags?page=1), 192.168.1.204:5000/swarm_push:latest

## Setup docker command on host machines for manifold 2G
Packages required:
- opencv 3.4.1
- cuda-9.0 library
- TX2 giving docker access to gpu(tx2-docker wrapper script under /bin)
- cv-bridge package with pointing to unique opencv 3.4.1
##### Purpose: 
- Run docker image to create docker container 
- Update docker image for distribution 
##### [Setup]{https://www.guguweb.com/2019/02/07/how-to-move-docker-data-directory-to-another-location-on-ubuntu/}:
1. Configure storage path for docker repository to /ssd/docker
Inside /etc/docker/daemon.json,
```
{
 "graph": "/ssd/docker"
}
```
2. Put [tx2-docker wrapper script](https://github.com/xyaoab/Swarm_Docker/blob/master/tx2-docker) under /bin 
The command passes required devices, library to the docker engine. 
3. Download [run_docker.sh](https://github.com/xyaoab/Swarm_Docker/blob/master/run_docker.sh) to host machines
4. Put [host_cmd.sh](https://github.com/xyaoab/Swarm_Docker/blob/master/host_cmd.sh) within docker image 

##### Usage:
Start docker container:
``` 
./run_docker.sh [FLAG] 
            	 -r read from SwarmConfig to execute 
            	 -e edit docker container 
            	 -d pull docker image from hub 
            	 -p pull docker image from private registry 
            	 -u update docker image to private registry 
            	 -h help

```
Stop docker container:
```
./stop_docker.sh
```
Stop all nodes:
```
stop_ros.sh
```

### Docker image push and pull pipeline 
#### For [docker private registry without certification](https://docs.docker.com/registry/insecure/)
##### Purpose: 
- Check docker image layer differnece between clients and server machine
- Only push/pull updated layer 
##### Usage:
1. Configure insecure registries on the server(IP: 192.168.1.204) and client machines 
  Inside /etc/docker/daemon.json, 
  ```
  {
  "live-restore": true,
  "group": "dockerroot",
  "insecure-registries": ["192.168.1.204:5000"]
  }
  ```
2. Restart the docker service for clients and server machines 
```
service docker restart
```
3. [Run a priavte registry on the server machine](https://ithelp.ithome.com.tw/articles/10191213)
```
docker run -d -p 5000:5000 -v /home/dji/storage:/var/lib/registry --name registry registry:2
```
- Use ```docker log registry``` to check registry log 
- Listening on port 5000
- Map to host machine storage path for docker images
4. Push the image from clients to docker registry
```
docker tag IMAGENAME 192.168.1.204:5000/IMAGENAME:latest
docker push 192.168.1.204:5000/IMAGENAME:latest
```
5. Pull the image from registry to clients
```
docker pull 192.168.1.204:5000/IMAGENAME:latest
```
6. Stop the private registry
```
docker container stop registry
```
7. Remove the private registry 
```
docker container rm -v registry
```
### Alternative: [Check binary difference of tar](https://github.com/dvddarias/docker-sync)
Docker save takes too much time for a image sizing 9.7G -- NOt feasible


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
3. cmake swarm_ws spackages  (remove swarm_detection[aruco]; cp usr/share/opencv; catkin build can't link header file[solved by catkin_make instead)

#### 2/15 Updates 
Logs:
1. pytorch 1.3.0 install from source, [reference](https://devtalk.nvidia.com/default/topic/1042821/jetson-tx2/pytorch-install-broken)
Inside CMakeLists.txt
```
export USE_NCLL=:OFF
export BUILD_CAFFE_OPS=:false
export TORCH_CUDA_ARCH_LIST="6.2"

```
2. Tensorflow [reference](https://devtalk.nvidia.com/default/topic/1038957/jetson-tx2/tensorflow-for-jetson-tx2-/)
```
sudo pip install --ignore-installed enum34
sudo pip install --extra-index-url=http://developer.download.nvidia.com/compute/redist/jp/v33/tensorflow-gpu/
```
NOTE: tensorrt is not yet installed
3. VINS-Fisheye
First-time user:
Inside vins_estimator/CMakeList.txt, after linking target executable
```
add_dependencies(vins_lib vins_generate_messages_cpp)
```
4. VisionWorks 
On host machine,
```
docker cp /var/cuda-repo-9-0-local [CONTAINER_ID]:/var/
```
Inside docker,
```
cd /var/cuda-repo-9-0-local
dpkg -i[cuda-license] 
dpkg -i [cuda-cudart] 
```
After install visionworks related .deb, g-streamer and the other dependencies are installed by 
```
apt-get -f install
```

To do list: 
- ~pass UART as device~
- ~contain DJI_SDK & UWB inside the docker~
- ~GCC V7 updates~
- move realsense drive and ros wrapper inside docker 
- ~test on uav~
- ~tensoflow & pytorch config~
- ~add docker run without shellscript~
- ~checking binary difference and patch updates~
- ptgrey fisheye driver in docker
