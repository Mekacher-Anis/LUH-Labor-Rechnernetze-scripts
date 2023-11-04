#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 5 ]; then
    echo "Usage: $0 <username> <password> <tc_interface_router1> <tc_interface_router2> <tso_interface>"
    exit 1
fi

run_stress_test_get_result() {  
  echo -e "\n\n\n Doing TCP stress test with buffer size $3 \n\n\n"

  # start iperf listener on receiver 1
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P 1 -p 5001 > /tmp/iperf_tcp_buff_$3.csv &"

  # start 10Mbit/s 30 Sekunden test between sender1 and receiver1
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 5001 -P 1 -t 60 &"

  sleep 70

  header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s'

  # get the iperf log from receiver1
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/iperf_tcp_buff_$3.csv ./output/iperf_tcp_receiver1_buff_$3.csv
  sed -i.old "1s;^;$header\n;" ./output/iperf_tcp_receiver1_buff_$3.csv
}


# disable TSO on all nodes
./run_disable_tso_on_targets.sh $1 $2 $5


# set buffer size 10 on router1 and router2
./set_link_capacity.sh $1 $2 10 $3 $4

# run stress test with buffer size 10
run_stress_test_get_result $1 $2 10

# set buffer size 100 on router1 and router2
./set_link_capacity.sh $1 $2 100 $3 $4

# run stress test with buffer size 100
run_stress_test_get_result $1 $2 100

