#!/bin/bash
# Usage: sudo disable_segmentation_offload.sh [interface_1] [interface_2] ... [interface_n]

# check params
if [ $# -lt 1 ]; then
    echo "Usage: sudo disable_segmentation_offload.sh [interface_1] [interface_2] ... [interface_n]"
    exit 1
fi

# ONLY DEACTIVATE TSO ON THE EXPERIMENT INTERFACES
for interface in "$@"
do
    echo $interface
    echo {{password}} | sudo -S ethtool -K $interface gro off
    echo {{password}} | sudo -S ethtool -K $interface gso off
    echo {{password}} | sudo -S ethtool -K $interface lro off
    echo {{password}} | sudo -S ethtool -K $interface ufo off
    echo {{password}} | sudo -S ethtool -K $interface tso off
    echo {{password}} | sudo -S ethtool -K $interface tx off
    echo {{password}} | sudo -S ethtool -K $interface sg off
sleep 1
done