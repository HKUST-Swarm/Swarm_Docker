#!/bin/bash
echo "Installing docker-engine"
sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

curl -fsSL https://yum.dockerproject.org/gpg | sudo apt-key add -

sudo add-apt-repository \
        "deb https://apt.dockerproject.org/repo/ \
            ubuntu-$(lsb_release -cs) \
                main"
sudo apt-get update
sudo apt-get -y install docker-engine
# add current user to docker group so there is no need to use sudo when running docker
sudo groupadd docker
sudo usermod -aG $(whoami)
newgrp docker

docker run hello-world
if docker run hello-world; then
    echo "Running docker successful"<F12>*
else
    echo "Could not get docker! Aborting." 1>&2
        exit 1
fii
