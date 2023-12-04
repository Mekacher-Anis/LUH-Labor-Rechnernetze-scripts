#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

echo "Traceroute with size 28"
sshpass -p $2 ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "traceroute -q 10 -z 0.5 receiver1 28 | tail -n 3 | sed 's/  /,/g'" > ./output/vpsp/sender1_receiver1_28.csv
echo "Traceroute with size 500"
sshpass -p $2 ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "traceroute -q 10 -z 0.5 receiver1 500 | tail -n 3 | sed 's/  /,/g'" > ./output/vpsp/sender1_receiver1_500.csv
echo "Traceroute with size 1000"
sshpass -p $2 ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "traceroute -q 10 -z 0.5 receiver1 1000 | tail -n 3 | sed 's/  /,/g'" > ./output/vpsp/sender1_receiver1_1000.csv