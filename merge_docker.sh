docker export --output=swarm2020.tar swarm
cat swarm2020.tar | docker import --change "ENV NVIDIA_VISIBLE_DEVICES=all" - swarm_merged
