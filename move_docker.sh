#!/bin/bash
git pull -f https://github.com/xyaoab/Swarm_Docker.git
sudo service docker stop
cd $HOME/Swarm_Docker
sudo cp ./daemon.json /etc/docker/daemon.json
sudo rsync -aP /var/lib/docker /ssd/
sudo mv /var/lib/docker /var/lib/docker.old
sudo service docker start
if ["$?"="0"];then
    echo "Docker changes to SSD"
    sudo rm -rf /var/lib/docker.old
else
    echo "Can't change docker directory" 1>&2
    exit 1
fi
