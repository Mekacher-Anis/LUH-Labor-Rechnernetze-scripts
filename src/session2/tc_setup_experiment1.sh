#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 3 ]; then
    echo "Usage: $0 <username> <password> <interface>"
    exit 1
fi

command=$(cat <<-EOF
sudo tc qdisc del dev $3 root 2>/dev/null &&
sudo tc qdisc replace dev $3 root handle 1:0 htb default 1 &&
sudo tc class add dev $3 parent 1:0 classid 1:1 htb rate 1000Mbit burst 15k &&
sudo tc qdisc add dev $3 parent 1:1 handle 2:0 prio priomap 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 &&
sudo tc qdisc add dev $3 parent 2:1 handle 3:0 sfq &&
sudo tc qdisc add dev $3 parent 2:2 handle 4:0 htb default 1 &&
sudo tc class add dev $3 parent 4:0 classid 4:1 htb rate 50mbit &&
sudo tc filter add dev $3 parent 2:0 prio 1 protocol ip u32 match ip dport 30001 0xffff flowid 2:1 &&
sudo tc filter add dev $3 parent 2:0 prio 2 protocol ip u32 match ip src 10.0.0.3/32 flowid 2:2 &&
sudo tc filter add dev $3 parent 2:0 prio 3 protocol all u32 match u32 0 0 flowid 2:3 &&
sudo tc filter add dev $3 parent 1:1 prio 1 protocol ip u32 match ip dport 30001 0xffff flowid 2:1 &&
sudo tc filter add dev $3 parent 1:1 prio 2 protocol ip u32 match ip src 10.0.0.3/32 flowid 2:2 &&
sudo tc filter add dev $3 parent 1:1 prio 3 protocol all u32 match u32 0 0 flowid 2:3 &&
sudo tc filter add dev $3 parent 1:0 prio 1 protocol ip u32 match ip dport 30001 0xffff flowid 2:1 &&
sudo tc filter add dev $3 parent 1:0 prio 2 protocol ip u32 match ip src 10.0.0.3/32 flowid 2:2 &&
sudo tc filter add dev $3 parent 1:0 prio 3 protocol all u32 match u32 0 0 flowid 2:3
EOF
)

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router1 "$command"



sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "iperf -s -y C -i 1 -u -P 1 -p 5001 > /tmp/tc_configuration_experiment1_0s.csv &"
  
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 5001 -u -P 1 -b 1000mbit -t 40 &"

sleep 20

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P 1 -p 5001 > /tmp/tc_configuration_experiment1_10s.csv &"
  
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 5001 -P 1 -t 60 &"

echo "Starting inter 1"

sleep 40

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "iperf -s -y C -i 1 -P 1 -p 30001 > /tmp/tc_configuration_experiment1_30s.csv &"
  
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 30001 -P 1 -t 60 &"

echo "Starting inter 2"

sleep 40

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -u -P 1 -p 30001 > /tmp/tc_configuration_experiment1_50s.csv &"
  
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 30001 -u -P 1 -b 1000mbit -t 20 &"

echo "Starting inter 3"

sleep 15

header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s'
  
sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/tc_configuration_experiment1_10s.csv ./output/exp1/tc_configuration_experiment1_10s.csv
sed -i.old "1s;^;$header\n;" ./output/exp1/tc_configuration_experiment1_10s.csv

sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2:/tmp/tc_configuration_experiment1_30s.csv ./output/exp1/tc_configuration_experiment1_30s.csv
sed -i.old "1s;^;$header\n;" ./output/exp1/tc_configuration_experiment1_30s.csv

header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s, Jitter ms, lost datagrams,total datagrams, lost datagrams in %,0'

sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2:/tmp/tc_configuration_experiment1_0s.csv ./output/exp1/tc_configuration_experiment1_0s.csv
sed -i.old "1s;^;$header\n;" ./output/exp1/tc_configuration_experiment1_0s.csv

sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/tc_configuration_experiment1_50s.csv ./output/exp1/tc_configuration_experiment1_50s.csv
sed -i.old "1s;^;$header\n;" ./output/exp1/tc_configuration_experiment1_50s.csv


echo -e "\n\n\nFinished"