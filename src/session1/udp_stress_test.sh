#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

# start iperf listener on receiver 1
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 'iperf -s -u -y C -i 1 -P 1 -p 5001 > /tmp/iperf.csv &'

# start iperf listener on receiver 2
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 'iperf -s -u -y C -i 1 -P 1 -p 5002 > /tmp/iperf.csv &'

# start 10Mbit/s 30 Sekunden test between sender1 and receiver1
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 5001 -u -b 10M -t 30 &"

# start 10Mbit/s 30 Sekunden test between sender2 and receiver2
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 5002 -u -b 10M -t 30 &"

sleep 40

header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s , Jitter ms, lost datagrams,total datagrams, lost datagrams in %,0'

# get the iperf log from receiver1
sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/iperf.csv ./output/iperf_udp_receiver1.csv
sed -i.old "1s;^;$header\n;" ./output/iperf_udp_receiver1.csv

# get the iperf log from receiver2
sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2:/tmp/iperf.csv ./output/iperf_udp_receiver2.csv
sed -i.old "1s;^;$header\n;" ./output/iperf_udp_receiver2.csv