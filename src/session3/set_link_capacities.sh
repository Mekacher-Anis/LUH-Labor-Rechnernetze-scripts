#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router1 "sudo tc qdisc replace dev eth0 root handle 1: netem rate 50mbit"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router1 "sudo tc qdisc replace dev eth1 root handle 1: netem rate 50mbit"

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router2 "sudo tc qdisc replace dev eth0 root handle 1: netem rate 50mbit"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router2 "sudo tc qdisc replace dev eth1 root handle 1: netem rate 50mbit"

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "sudo tc qdisc replace dev eth0 root handle 1: netem rate 100mbit"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "sudo tc qdisc replace dev eth0 root handle 1: netem rate 100mbit"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "sudo tc qdisc replace dev eth0 root handle 1: netem rate 100mbit"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "sudo tc qdisc replace dev eth0 root handle 1: netem rate 100mbit"