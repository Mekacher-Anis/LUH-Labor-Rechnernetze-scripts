#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 3 ]; then
    echo "Usage: $0 <username> <password> <interface>"
    exit 1
fi

command=$(cat <<-EOF
sudo tc qdisc replace dev $3 root handle 1:0 htb default 1 &&
sudo tc class add dev $3 parent 1:0 classid 1:1 htb rate 25Mbit ceil 25Mbit burst 15k &&
sudo tc class add dev $3 parent 1:1 classid 1:10 htb rate 20Mbit ceil 20Mbit burst 15k &&
sudo tc class add dev $3 parent 1:1 classid 1:20 htb rate 5Mbit ceil 25Mbit burst 15k &&
sudo tc class add dev $3 parent 1:10 classid 1:11 htb rate 8Mbit ceil 20Mbit burst 15k &&
sudo tc class add dev $3 parent 1:10 classid 1:12 htb rate 8Mbit ceil 20Mbit burst 15k &&
sudo tc class add dev $3 parent 1:10 classid 1:13 htb rate 4Mbit ceil 20Mbit burst 15k &&
sudo tc qdisc add dev $3 parent 1:13 handle 113:0 sfq &&
sudo tc class add dev $3 parent 1:20 classid 1:21 htb rate 2Mbit ceil 25Mbit burst 15k &&
sudo tc class add dev $3 parent 1:20 classid 1:22 htb rate 2Mbit ceil 25Mbit burst 15k &&
sudo tc class add dev $3 parent 1:20 classid 1:23 htb rate 1Mbit ceil 25Mbit burst 15k &&
sudo tc qdisc add dev $3 parent 1:23 handle 123:0 sfq &&
sudo tc filter add dev $3 parent 1:0 prio 2 protocol ip u32 match ip dport 30001 0xffff match ip dst 10.3.0.2/32 flowid 1:11 &&
sudo tc filter add dev $3 parent 1:0 prio 2 protocol ip u32 match ip dport 30002 0xffff match ip dst 10.3.0.2/32 flowid 1:12 &&
sudo tc filter add dev $3 parent 1:0 prio 2 protocol ip u32 match ip dport 30003 0xffff match ip dst 10.3.0.2/32 flowid 1:13 &&
sudo tc filter add dev $3 parent 1:0 prio 2 protocol ip u32 match ip dport 30004 0xffff match ip dst 10.3.0.2/32 flowid 1:13 &&
sudo tc filter add dev $3 parent 1:0 prio 2 protocol ip u32 match ip dport 30001 0xffff match ip dst 10.4.0.2/32 flowid 1:21 &&
sudo tc filter add dev $3 parent 1:0 prio 2 protocol ip u32 match ip dport 30002 0xffff match ip dst 10.4.0.2/32 flowid 1:22 &&
sudo tc filter add dev $3 parent 1:0 prio 2 protocol ip u32 match ip dport 30003 0xffff match ip dst 10.4.0.2/32 flowid 1:23 &&
sudo tc filter add dev $3 parent 1:0 prio 2 protocol ip u32 match ip dport 30004 0xffff match ip dst 10.4.0.2/32 flowid 1:23
EOF
)


# sudo tc filter add dev eth1 parent 1:1 prio 2 protocol ip u32 match ip dst 10.1.0.3/32 flowid 1:10 &&
# sudo tc filter add dev eth1 parent 1:1 prio 2 protocol ip u32 match ip dst 10.1.0.4/32 flowid 1:20 &&
# sudo tc filter add dev eth1 parent 1:0 prio 2 protocol ip u32 match ip dst 10.1.0.3/32 flowid 1:10 &&
# sudo tc filter add dev eth1 parent 1:0 prio 2 protocol ip u32 match ip dst 10.1.0.4/32 flowid 1:20 &&

# sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router1 "$command"

two_tcp_flows() {
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P 1 -p 30001 > /tmp/two_concurrent_tcp_streams_$3.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "iperf -s -y C -i 1 -P 1 -p 30001 > /tmp/two_concurrent_tcp_streams_$3.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 30001 -P 1 -t 40 &"

  sleep 20
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 30001 -P 1 -t 20 &"
  
  sleep 20
  
  header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s'
  
  # get the iperf log from receiver1
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/two_concurrent_tcp_streams_$3.csv ./output/exp2/$3/two_concurrent_tcp_streams_receiver1.csv
  sed -i.old "1s;^;$header\n;" ./output/exp2/$3/two_concurrent_tcp_streams_receiver1.csv
  
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2:/tmp/two_concurrent_tcp_streams_$3.csv ./output/exp2/$3/two_concurrent_tcp_streams_receiver2.csv
  sed -i.old "1s;^;$header\n;" ./output/exp2/$3/two_concurrent_tcp_streams_receiver2.csv
}

three_tcp_flows_to_receiver1() {
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P 1 -p 30001 > /tmp/three_concurrent_tcp_streams_${3}_30001.csv &"
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P 1 -p 30002 > /tmp/three_concurrent_tcp_streams_${3}_30002.csv &"
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P 1 -p 30003 > /tmp/three_concurrent_tcp_streams_${3}_30003.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 30001 -P 1 -t 60 &"
  sleep 20
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 30002 -P 1 -t 40 &"
  sleep 20
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 30003 -P 1 -t 20 &"
  sleep 25
  
  header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s'
  
  # get the iperf log from receiver1
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/three_concurrent_tcp_streams_${3}_30001.csv ./output/exp2/$3/three_concurrent_tcp_streams_receiver1_30001.csv
  sed -i.old "1s;^;$header\n;" ./output/exp2/$3/three_concurrent_tcp_streams_receiver1_30001.csv
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/three_concurrent_tcp_streams_${3}_30002.csv ./output/exp2/$3/three_concurrent_tcp_streams_receiver1_30002.csv
  sed -i.old "1s;^;$header\n;" ./output/exp2/$3/three_concurrent_tcp_streams_receiver1_30002.csv
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/three_concurrent_tcp_streams_${3}_30003.csv ./output/exp2/$3/three_concurrent_tcp_streams_receiver1_30003.csv
  sed -i.old "1s;^;$header\n;" ./output/exp2/$3/three_concurrent_tcp_streams_receiver1_30003.csv
}

three_tcp_flows_to_receiver2() {
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "iperf -s -y C -i 1 -P 1 -p 30001 > /tmp/three_concurrent_tcp_streams_${3}_30001.csv &"
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "iperf -s -y C -i 1 -P 1 -p 30002 > /tmp/three_concurrent_tcp_streams_${3}_30002.csv &"
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "iperf -s -y C -i 1 -P 1 -p 30003 > /tmp/three_concurrent_tcp_streams_${3}_30003.csv &"
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P 1 -p 30001 > /tmp/three_concurrent_tcp_streams_${3}_30001.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 30001 -P 1 -t 90 &"
  sleep 20
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 30002 -P 1 -t 70 &"
  sleep 20
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 30003 -P 1 -t 50 &"
  sleep 20
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 30001 -P 1 -t 30 &"
  sleep 35
  
  header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s'
  
  # get the iperf log from receiver2
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2:/tmp/three_concurrent_tcp_streams_${3}_30001.csv ./output/exp2/$3/three_concurrent_tcp_streams_receiver2_30001.csv
  sed -i.old "1s;^;$header\n;" ./output/exp2/$3/three_concurrent_tcp_streams_receiver2_30001.csv
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2:/tmp/three_concurrent_tcp_streams_${3}_30002.csv ./output/exp2/$3/three_concurrent_tcp_streams_receiver2_30002.csv
  sed -i.old "1s;^;$header\n;" ./output/exp2/$3/three_concurrent_tcp_streams_receiver2_30002.csv
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2:/tmp/three_concurrent_tcp_streams_${3}_30003.csv ./output/exp2/$3/three_concurrent_tcp_streams_receiver2_30003.csv
  sed -i.old "1s;^;$header\n;" ./output/exp2/$3/three_concurrent_tcp_streams_receiver2_30003.csv
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/three_concurrent_tcp_streams_${3}_30001.csv ./output/exp2/$3/three_concurrent_tcp_streams_receiver1_30001.csv
  sed -i.old "1s;^;$header\n;" ./output/exp2/$3/three_concurrent_tcp_streams_receiver1_30001.csv
}

one_tcp_to_30003_one_udp_to_30004() {
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P 1 -p 30003 > /tmp/one_tcp_to_30003_one_udp_to_30004_tcp.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -u -P 1 -p 30004 > /tmp/one_tcp_to_30003_one_udp_to_30004_udp.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 30003 -P 1 -t 40 &"

  sleep 20
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 30004 -u -b 20mbit -P 1 -t 20 &"
  
  sleep 20
  
  header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s'
  
  # get the iperf log from receiver1
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/one_tcp_to_30003_one_udp_to_30004_tcp.csv ./output/exp2/$3/one_tcp_to_30003_one_udp_to_30004_tcp.csv
  sed -i.old "1s;^;$header\n;" ./output/exp2/$3/one_tcp_to_30003_one_udp_to_30004_tcp.csv

  header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s, Jitter ms, lost datagrams,total datagrams, lost datagrams in %,0'
  
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/one_tcp_to_30003_one_udp_to_30004_udp.csv ./output/exp2/$3/one_tcp_to_30003_one_udp_to_30004_udp.csv
  sed -i.old "1s;^;$header\n;" ./output/exp2/$3/one_tcp_to_30003_one_udp_to_30004_udp.csv
}

# two_tcp_flows $1 $2 r1vr2

# three_tcp_flows_to_receiver1 $1 $2 "3tor1"

# three_tcp_flows_to_receiver2 $1 $2 "3tor2"

one_tcp_to_30003_one_udp_to_30004 $1 $2 "udp_tcp_2_30003"
