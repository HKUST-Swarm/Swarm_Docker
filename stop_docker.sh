#!/usr/bin/env bash
ID="$(docker ps -l -q)"
echo ${ID}
docker container stop swarm
stop_ros.sh
#sudo service network-manager restart
