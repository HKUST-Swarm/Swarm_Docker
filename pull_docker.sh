#!/bin/bash
sudo -S sh -c 'echo 2048 > /sys/module/usbcore/parameters/usbfs_memory_mb'
#echo "input is: $1"
export LANG=C

HOSTNAME=8.8.8.8
ID=4
REMOTE_IMAGE=xyaoab/swarmuav:latest
SERVER_IMAGE=192.168.1.204:5000/swarm:latest
SERVER=1
if [ "$#" -gt 0  ]
then
    echo "Pull from hub"
    IMAGE=$REMOTE_IMAGE
    SERVER=0
else
    echo "Pull from i7"
    IMAGE=$SERVER_IMAGE
fi
#ping -c1 8.8.8.8 > /dev/null
#echo $?
#while  ping -c1 {$HOSTNAME} &>/dev/null
#        do echo "Ping Fail - `date`"
while ! sudo /sbin/ethtool eth0 | grep -q "Link detected: yes"
    do echo "No connection"
        /bin/sleep 5
done
echo "`date`--Start pulling docker image"
if [ $SERVER -eq 1 ]
then
    wget http://i7/pull_$ID
fi

if docker pull $IMAGE | grep "Image is up to date";then
	if [ $SERVER -eq 1 ]
    then
        wget http://i7/ok_$ID
    fi
    echo "up to date"
else
	if [ $SERVER -eq 1 ]
    then
        wget http://i7/pull_ok_$ID
    fi
    echo "pulling new image"
fi
