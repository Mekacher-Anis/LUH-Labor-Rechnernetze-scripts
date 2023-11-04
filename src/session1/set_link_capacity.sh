#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 5 ]; then
    echo "Usage: $0 <username> <password> <buffer_size> <interface_router1> <interface_router2>"
    exit 1
fi

command=$(cat <<-EOF
echo $2 | sudo -S tc qdisc replace dev $4 root handle 1: htb default 10 &&
echo $2 | sudo -S tc class add dev $4 parent 1: classid 1:10 htb rate 20Mbit burst 15k &&
echo $2 | sudo -S tc qdisc add dev $4 parent 1:10 handle 10: netem delay 10ms limit $3
EOF
)

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router1 "$command"

command=$(cat <<-EOF
echo $2 | sudo -S tc qdisc replace dev $5 root handle 1: htb default 10 &&
echo $2 | sudo -S tc class add dev $5 parent 1: classid 1:10 htb rate 20Mbit burst 15k &&
echo $2 | sudo -S tc qdisc add dev $5 parent 1:10 handle 10: netem delay 10ms limit 10
EOF
)

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router2 "$command"

