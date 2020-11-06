sudo ifconfig eth0 192.168.1.20$1
sudo ip route delete default
sudo ip route add default via 192.168.1.1 dev eth0
