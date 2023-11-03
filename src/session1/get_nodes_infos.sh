#!/bin/bash

# if no username and password are provided, exit and print the usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

# login to all the nodes using ssh consecutively and run 'ifconfig' and 'ping' all the other nodes
# and save the output in a file named 'node_info.txt' in the current directory

# get all the nodes name from the file 'nodes.txt'
nodes=$(cat nodes.txt)

# create array from the nodes names
nodes_array=($nodes)

# create an empty array to save the nodes ping info
nodes_ping_info=()

# create an empty array to save the nodes traceroute info
nodes_traceroute_info=()

# create an empty array to save the nodes ifconfig info
nodes_ifconfig_info=()

# loop over all the nodes and get the info
for node in "${nodes_array[@]}"
do
    echo "Getting info from $node"

    # get the node ifconfig info and save it in the nodes_ifconfig_info array
    node_ifconfig_info=$(sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@${node} 'ifconfig')
    # add the node name to the output
    node_ifconfig_info="\n\n\n++++++++++++++++++++++ $node ++++++++++++++++++++++\n\n\n"
    nodes_ifconfig_info+=($node_ifconfig_info)

    echo "Pinging $node"

    # loop over all the nodes and ping them
    for node2 in "${nodes_array[@]}"
    do
        echo -n "+"
        # ping the node2 from node and save the output in the nodes_ping_info array
        node_ping_info=$(sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@${node} 'ping -c 1' ${node2})
        # add the source and destination nodes to the output
        node_ping_info="\n\n\n++++++++++++++++++++++ $node -> $node2 ++++++++++++++++++++++\n\n\n"
        nodes_ping_info+=($node_ping_info)

        # traceroute the node2 from node and save the output in the nodes_traceroute_info array
        node_traceroute_info=$(sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@${node} 'traceroute' ${node2})
        # add the source and destination nodes to the output
        node_traceroute_info="\n\n\n++++++++++++++++++++++ $node -> $node2 ++++++++++++++++++++++\n\n\n"
        nodes_traceroute_info+=($node_traceroute_info)
    done
done

# save the nodes ping info in a file named 'node_ping_info.txt'
echo -e "${nodes_ping_info[@]}" > node_ping_info.txt

# save the nodes ping info in a file named 'node_ifconfig_info.txt'
echo -e "${nodes_ifconfig_info[@]}" > node_ifconfig_info.txt

# save the nodes ping info in a file named 'node_traceroute_info.txt'
echo -e "${nodes_traceroute_info[@]}" > node_traceroute_info.txt