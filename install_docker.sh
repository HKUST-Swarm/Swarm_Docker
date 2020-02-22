#!/bin/bash
echo "Installing docker-engine"
sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
       "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) \
             stable"
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
# add current user to docker group so there is no need to use sudo when running docker
sudo groupadd docker
sudo usermod -aG docker $(whoami)
newgrp docker

docker run hello-world
if docker run hello-world; then
    echo "Running docker successful"
else
    echo "Could not get docker! Aborting." 1>&2
        exit 1
fi
