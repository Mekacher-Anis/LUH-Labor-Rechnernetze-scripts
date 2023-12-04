#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

# $1 username $2 password $3 queueing discipline
two_tcp_flows() {
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P 1 -p 5001 > /tmp/two_concurrent_tcp_streams_$3.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "iperf -s -y C -i 1 -P 1 -p 5001 > /tmp/two_concurrent_tcp_streams_$3.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 5001 -P 1 -t 60 &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 5001 -P 1 -t 60 &"
  
  sleep 70
  
  header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s'
  
  # get the iperf log from receiver1
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/two_concurrent_tcp_streams_$3.csv ./output/$3/two_concurrent_tcp_streams_receiver1.csv
  sed -i.old "1s;^;$header\n;" ./output/$3/two_concurrent_tcp_streams_receiver1.csv
  
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2:/tmp/two_concurrent_tcp_streams_$3.csv ./output/$3/two_concurrent_tcp_streams_receiver2.csv
  sed -i.old "1s;^;$header\n;" ./output/$3/two_concurrent_tcp_streams_receiver2.csv
}

# $1 username $2 password $3 queueing discipline $4 udp bandwidth
one_tcp_one_udp() {
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P 1 -p 5001 > /tmp/one_tcp_one_udp_${4}_$3.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "iperf -s -u -y C -i 1 -P 1 -p 5001 > /tmp/one_tcp_one_udp_${4}_$3.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 5001 -P 1 -t 60 &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 5001 -u -b $4 -P 1 -t 60 &"
  
  sleep 70
  
  header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s'
  
  # get the iperf log from receiver1
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/one_tcp_one_udp_${4}_$3.csv ./output/$3/one_tcp_one_udp_${4}_receiver1.csv
  sed -i.old "1s;^;$header\n;" ./output/$3/one_tcp_one_udp_${4}_receiver1.csv
  
  header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s, Jitter ms, lost datagrams,total datagrams, lost datagrams in %,0'
  
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2:/tmp/one_tcp_one_udp_${4}_$3.csv ./output/$3/one_tcp_one_udp_${4}_receiver2.csv
  sed -i.old "1s;^;$header\n;" ./output/$3/one_tcp_one_udp_${4}_receiver2.csv
}

# $1 username $2 password $3 queueing discipline
two_udp_flows() {
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -u -y C -i 1 -P 1 -p 5001 > /tmp/two_udp_flows_$3.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "iperf -s -u -y C -i 1 -P 1 -p 5001 > /tmp/two_udp_flows_$3.csv &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 5001 -u -b 600mbit -P 1 -t 60 &"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 5001 -u -b 750mbit -P 1 -t 60 &"
  
  sleep 70
  
  header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s, Jitter ms, lost datagrams,total datagrams, lost datagrams in %,0'
  
  # get the iperf log from receiver1
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/two_udp_flows_$3.csv ./output/$3/two_udp_flows_receiver1.csv
  sed -i.old "1s;^;$header\n;" ./output/$3/two_udp_flows_receiver1.csv
  
  
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2:/tmp/two_udp_flows_$3.csv ./output/$3/two_udp_flows_receiver2.csv
  sed -i.old "1s;^;$header\n;" ./output/$3/two_udp_flows_receiver2.csv
}


# setup fifo queueing discipline on router1
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router1 "sudo tc qdisc replace dev enp101s0f0 root handle 1: bfifo"

two_tcp_flows $1 $2 "fifo"

one_tcp_one_udp $1 $2 "fifo" "250M"

one_tcp_one_udp $1 $2 "fifo" "750M"

two_udp_flows $1 $2 "fifo"

# setup SFQ queueing discipline on router1
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router1 "sudo tc qdisc del dev enp101s0f0 root && sudo tc qdisc replace dev enp101s0f0 root handle 1: sfq"

two_tcp_flows $1 $2 "sfq"

one_tcp_one_udp $1 $2 "sfq" "250M"

one_tcp_one_udp $1 $2 "sfq" "750M"

two_udp_flows $1 $2 "sfq"

# setup TBF queueing discipline on router1
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@router1 "sudo tc qdisc del dev enp101s0f0 root && sudo tc qdisc replace dev enp101s0f0 root handle 1: tbf rate 500mbit burst 1250mbit latency 1"

two_tcp_flows $1 $2 "tbf"

one_tcp_one_udp $1 $2 "tbf" "250M"

one_tcp_one_udp $1 $2 "tbf" "750M"

two_udp_flows $1 $2 "tbf"
