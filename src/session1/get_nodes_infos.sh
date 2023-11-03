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

# loop over all the nodes and get the info
for node in "${nodes_array[@]}"
do
    echo "Getting info from $node"

    # get the node ifconfig info and save it in the nodes_ifconfig_info array
    # add the node name to the output
    echo -e "\n\n\n++++++++++++++++++++++ $node ++++++++++++++++++++++\n\n\n" >> ./output/node_ifconfig_info.txt
    sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@$node 'ifconfig' >> ./output/node_ifconfig_info.txt
    nodes_ifconfig_info+="\n\n\n"

    echo "Pinging/traceroute from $node"

    # loop over all the nodes and ping them
    for node2 in "${nodes_array[@]}"
    do
        echo -n "+"

        # ping the node2 from node and save the output in the nodes_ping_info array
        echo -e "\n\n\n++++++++++++++++++++++ $node -> $node2 ++++++++++++++++++++++\n\n\n" >> ./output/node_ping_info.txt
        sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@${node} 'ping -c 1' ${node2} >> ./output/node_ping_info.txt

        # traceroute the node2 from node and save the output in the nodes_traceroute_info array
        echo -e "\n\n\n++++++++++++++++++++++ $node -> $node2 ++++++++++++++++++++++\n\n\n" >> ./output/node_traceroute_info.txt
        sshpass -p $2 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o ConnectionAttempts=3 $1@${node} "traceroute $node2" >> ./output/node_traceroute_info.txt
    done

    echo -e "\n\n\n\n"
done

echo ""