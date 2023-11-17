#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router1 "tc qdisc add dev eth1 root pfifo limit 1000"