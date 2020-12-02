#!/usr/bin/env bash
echo "Stop bag record"
while IFS='' read -r line || [[ -n "$line" ]]; do
    IFS=':' inarr=(${line})
    if [ ${inarr[0]} = "rosbag" ]; then
        echo "Killing $line with ${inarr[1]}"
        sudo kill -INT ${inarr[1]}
    fi
done < /home/dji/swarm_log_latest/pid_bag.txt

