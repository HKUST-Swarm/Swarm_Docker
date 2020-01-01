#!/usr/bin/env bash
ID="$(docker ps -l -q)"
echo ${ID}
docker container stop ${ID} && docker rm ${ID}
