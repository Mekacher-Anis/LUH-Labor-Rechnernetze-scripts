# start iperf listener on receiver 1 and 2
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "iperf -s -y C -i 1 -P 1 -p 5001 > /tmp/iperf_tcp_reno_2_receiver1.csv &"
sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "iperf -s -u -y C -i 1 -P 3 -p 5001 > /tmp/iperf_udp_receiver2.csv &"

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "iperf -c receiver1 -p 5001 -P 1 -t 120 &"

sleep 30

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 5001 -t 20 -u -b 10M &"

sleep 30

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 5001 -t 20 -u -b 30M &"

sleep 30

sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "iperf -c receiver2 -p 5001 -t 20 -u -b 50M &"

sleep 40

header='timestamp,Snd IP,Snd port,RCV IP,RCV port,ID,report time,sent data Bytes,throughput bits/s'

# get the iperf log from receiver1
sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1:/tmp/iperf_tcp_reno_2_receiver1.csv ./output/iperf_tcp_2_reno_receiver1.csv
sed -i.old "1s;^;$header\n;" ./output/iperf_tcp_2_reno_receiver1.csv

sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2:/tmp/iperf_udp_receiver2.csv ./output/iperf_udp_receiver2.csv
sed -i.old "1s;^;$header\n;" ./output/iperf_udp_receiver2.csv