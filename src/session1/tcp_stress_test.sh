#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

# do tcp stress test with 1, 2, and 4 parallel streams
for i in 1 2 4
do
    echo -e "\n\n\n Doing TCP stress test with $i parallel streams \n\n\n"

    # start iperf listener on receiver 1
    sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P $i -p 5001 > /tmp/iperf_tcp_$i.csv &"

    # start 10Mbit/s 30 Sekunden test between sender1 and receiver1
    sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 5001 -P $i -t 60 &"

    sleep 70

    header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s'

    # get the iperf log from receiver1
    sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/iperf_tcp_$1.csv ./output/iperf_tcp_receiver1_$i.csv
    sed -i.old "1s;^;$header\n;" ./output/iperf_tcp_receiver1_$i.csv

    echo "Done with $i parallel streams"
done
