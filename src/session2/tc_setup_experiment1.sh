#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

command=$(cat <<-EOF
tc qdisc replace dev eth1 root handle 1:0 htb &&
tc class add dev eth1 parent 1:0 classid 1:1 htb rate 1000Mbit burst 15k &&
tc qdisc add dev eth1 parent 1:1 handle 2:0 prio &&
tc qdisc add dev eth1 parent 2:1 handle 3:0 sfq &&
tc qdisc add dev eth1 parent 2:2 handle 4:0 htb &&
tc class add dev eth1 parent 4:0 classid 4:1 htb rate 50mbit &&
tc filter add dev eth1 parent 1:0 prio 1 protocol ip u32 match ip dport 30001 0xffff flowid 2:1 &&
tc filter add dev eth1 parent 1:0 prio 2 protocol ip u32 match ip src 10.0.0.3/32 flowid 2:2
EOF
)