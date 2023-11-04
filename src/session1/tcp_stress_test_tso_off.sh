#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

# start iperf listener on receiver 1
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "rm -f /tmp/iperf_tcp_tso_off.csv && iperf -s -y C -i 1 -P 1 -p 5001 > /tmp/iperf_tcp_tso_off.csv &"

# start tcpdump on router1 to capture the traffic
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router1 "echo $2 | sudo -S tcpdump -G 15 -W 1 -n -i eth0 -w /tmp/report.pcap host sender1 and host receiver1 &"

# start 10Mbit/s 30 Sekunden test between sender1 and receiver1
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 5001 -P 1 -t 10 &"

sleep 20

# get the tcp dump from router1
sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router1:/tmp/report.pcap ./output/report_tso_off.pcap


