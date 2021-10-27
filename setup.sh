#!/bin/bash

# NOTE: this setup script will be executed right before the launcher file inside the container,
#       use it to configure your environment.

set -eu

# constants
export VT=1
export XORG_CONFIG=./assets/xorg.nvidia.conf

if [ -z ${BUS_ID+x} ]; then
    echo "Environment variable BUS_ID is not set. Use 'nvidia-xconfig --query-gpu-info' to find the PCI Bus ID of the GPU you want to use."
    exit 1
else
    echo "BUS_ID is set to '$BUS_ID'"
fi

# replace placeholder BUS_ID
sed -i "s/NVIDIA_PCI_BUS_ID/${BUS_ID}/g" "${XORG_CONFIG}"

set +eu