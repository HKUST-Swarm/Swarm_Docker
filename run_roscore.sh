#!/usr/bin/env bash
source /root/SwarmConfig/configs.sh

roscore &> $LOG_PATH/log_roscore.txt &
