#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

# stop spruce on sender1 and receiver1
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "sudo pkill spruce_rcv"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "sudo pkill spruce_snd"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "sudo pkill iperf"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "sudo pkill iperf"


# copy spruce to sender1 and receiver1
sshpass -p $2 scp ./spruce_snd $1@sender1:/tmp/spruce_snd
sshpass -p $2 scp ./spruce_rcv $1@receiver1:/tmp/spruce_rcv

# run spruce on sender1 and receiver1
echo "XT_Rate,Throughput" > ./output/spruce/spruce.csv
echo -n "0," >> ./output/spruce/spruce.csv
echo "Running spruce on sender1 and receiver1 without cross traffic"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "sudo /tmp/spruce_rcv &"
sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "sudo /tmp/spruce_snd -h receiver1 -c 50M" >> ./output/spruce/spruce.csv

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "iperf -s -t 36000 -u >/dev/null 2>&1"

for rate in {1..10}
do
  XTRATE=$(($rate*10))
  echo "Running spruce on sender1 and receiver1 without cross traffic rate $XTRATE Mbit/s"
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "sudo pkill spruce_rcv"
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "sudo pkill spruce_snd"
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "sudo pkill iperf"

  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -t 60 -u -l 50 -b ${XTRATE}M >/dev/null 2>&1 &"
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "/tmp/spruce_rcv &"
  echo -n "$XTRATE," >> ./output/spruce/spruce.csv
  sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "/tmp/spruce_snd -h receiver1 -c 50M" >> ./output/spruce/spruce.csv
done

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "sudo pkill spruce_rcv"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "sudo pkill spruce_snd"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "sudo pkill iperf"