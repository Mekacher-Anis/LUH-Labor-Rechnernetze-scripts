#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

retrieveLog() {
  sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@$3:/tmp/$4 ./output/test_fifo/$4
  ITGDec ./output/test_fifo/$4 -c 1000 ./output/test_fifo/$5
  header="Time Bitrate Delay Jitter Loss"
  sed -i.old "1s;^;$header\n;" ./output/test_fifo/$5
  rm -f ./output/test_fifo/$5.old
  sed -i.old "s/\s\+/,/g" ./output/test_fifo/$5
  rm -f ./output/test_fifo/$5.old
}

for rate in {1..10}
do
  XTPRATE=$((625*2*$rate))
  XTRATE=$(($rate*10))
  echo "XTPRATE: $XTPRATE"
  
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "nohup ITGRecv >/dev/null 2>&1 </dev/null &"
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "nohup ITGRecv >/dev/null 2>&1 </dev/null &"
  sender1Command="ITGSend -C 6250 -c 1000 -t 10000 -l /tmp/test_fifo_sender1_cbr_${XTRATE}.log -x /tmp/test_fifo_receiver1_cbr_${XTRATE}.log -a receiver1 &"
  sshpass -p $2 ssh -f -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 $sender1Command
  sender2Command="ITGSend -C $XTPRATE -c 1000 -t 10000 -l /tmp/test_fifo_sender2_xt_${XTRATE}.log -x /tmp/test_fifo_receiver2_xt_${XTRATE}.log -a receiver2 &"
  sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 $sender2Command

  retrieveLog $1 $2 sender1 test_fifo_sender1_cbr_${XTRATE}.log test_fifo_sender1_cbr_${XTRATE}.csv
  retrieveLog $1 $2 receiver1 test_fifo_receiver1_cbr_${XTRATE}.log test_fifo_receiver1_cbr_${XTRATE}.csv
  retrieveLog $1 $2 sender2 test_fifo_sender2_xt_${XTRATE}.log test_fifo_sender2_xt_${XTRATE}.csv
  retrieveLog $1 $2 receiver2 test_fifo_receiver2_xt_${XTRATE}.log test_fifo_receiver2_xt_${XTRATE}.csv
done

sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver1 "pkill ITGRecv"
sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@receiver2 "pkill ITGRecv"
sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender1 "pkill ITGSend"
sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@sender2 "pkill ITGSend"

# sshpass -p password ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 root@receiver1 "pkill ITGRecv"
# sshpass -p password ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 root@receiver2 "pkill ITGRecv"
# sshpass -p password ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 root@sender1 "pkill ITGSend"
# sshpass -p password ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 root@sender2 "pkill ITGSend"