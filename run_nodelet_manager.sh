source /root/SwarmConfig/configs.sh
export LD_PRELOAD=/usr/lib/gcc/aarch64-linux-gnu/7/libgomp.so
#nice --20 taskset -c 0,3,4,5 rosrun nodelet nodelet manager __name:=swarm_manager --no-bond &> $LOG_PATH/log_nodelet.txt &
ice --20 rosrun nodelet nodelet manager __name:=swarm_manager --no-bond &> $LOG_PATH/log_nodelet.txt &
