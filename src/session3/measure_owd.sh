#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 3 ]; then
    echo "Usage: $0 <username> <password> <sync>"
    exit 1
fi

measure_owd_between_sender_receiver() {
    # $1: username
    # $2: password
    # $3: sender
    # $4: receiver
    # $5: sync
    echo -e "Measuring one-way delay between $3 and $4"

    # synchronize the time between the sender and the receiver if the sync flag is set
    if [ $5 -eq 1 ]; then
        echo -e "Synchronizing the time between $3 and the $4"
        sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@$4 "sudo /etc/init.d/ntp stop && sudo ntpdate -b ntp1"
        sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@$3 "sudo /etc/init.d/ntp stop && sudo ntpdate -b ntp1"
        echo -e "Synchronised !!"
    fi

    sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@$4 "nohup ITGRecv >/dev/null 2>&1 </dev/null &"
    sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@$3 "ITGSend -x /tmp/ITG_${3}_${4}_${5}.log -t 60000 -c 1000 -C 850 -a $4 &"

    sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@$4 "pkill ITGRecv"
    sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@$3 "pkill ITGSend"

    sshpass -p $2 scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@$4:/tmp/ITG_${3}_${4}_${5}.log ./output/owd_${5}/${3}_${4}/ITG_${3}_${4}.log

    ITGDec ./output/owd_${5}/${3}_${4}/ITG_${3}_${4}.log -c 1000 ./output/owd_${5}/${3}_${4}/combined_stats.csv
    ITGDec ./output/owd_${5}/${3}_${4}/ITG_${3}_${4}.log > ./output/owd_${5}/${3}_${4}/info.txt

    header="Time Bitrate Delay Jitter Loss"
    sed -i.old "1s;^;$header\n;" ./output/owd_${5}/${3}_${4}/combined_stats.csv
    rm -f ./output/owd_${5}/${3}_${4}/combined_stats.csv.old
    sed -i.old "s/\s\+/,/g" ./output/owd_${5}/${3}_${4}/combined_stats.csv
    rm -f ./output/owd_${5}/${3}_${4}/combined_stats.csv.old

    echo -e "Done!\n\n"
}

measure_owd_between_sender_receiver $1 $2 sender1 receiver1 $3
measure_owd_between_sender_receiver $1 $2 sender1 receiver2 $3
measure_owd_between_sender_receiver $1 $2 sender2 receiver1 $3
measure_owd_between_sender_receiver $1 $2 sender2 receiver2 $3