#!/usr/bin/env bash
ID="$(docker ps -l -q)"
echo ${ID}
docker container stop swarm
/home/dji/Swarm_Docker/stop_bag.sh