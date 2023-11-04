#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 3 ]; then
  echo "Usage: $0 <username> <password> <interface>"
  exit 1
fi

# I didn't use scp on purpose
# read "./disable_segmentation_offload.sh" and replace {{password}} with $2
# then put result on all nodes
# then execute it on all nodes

custom_disble_tso=$(sed "s/{{password}}/$2/" disable_segmentation_offload.sh)

# get all the nodes name from the file 'nodes.txt'
nodes=$(cat nodes.txt)

# create array from the nodes names
nodes_array=($nodes)

# loop over all the nodes and get the info
for node in "${nodes_array[@]}"
do
  echo "Disabling TSO on $node"

  sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@$node "echo '$custom_disble_tso' > /tmp/disable_segmentation_offload.sh && chmod +x /tmp/disable_segmentation_offload.sh && /tmp/disable_segmentation_offload.sh $3 && rm /tmp/disable_segmentation_offload.sh"
done