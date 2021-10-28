#!/bin/bash

# NOTE: this setup script will be executed right before the launcher file inside the container,
#       use it to configure your environment.

# constants
export VT=1
export XORG_CONFIG=./assets/xorg.nvidia.conf

if [ -z ${BUS_ID+x} ]; then
    echo "CRITICAL: Environment variable BUS_ID is not set. Use 'nvidia-xconfig --query-gpu-info' to find the PCI Bus ID of the GPU you want to use."
    exit 1
else
    if [ -z ${_BUS_ID_CONFIGURED+x} ]; then
        echo "BUS_ID is set to '$BUS_ID'"
    fi
fi

# replace placeholder BUS_ID
sed -i "s/NVIDIA_PCI_BUS_ID/${BUS_ID}/g" "${XORG_CONFIG}"
export _BUS_ID_CONFIGURED=1

# check whether nvidia_drv.so was mounted
GUEST_NVIDIA_XORG_DRV=/usr/lib/xorg/modules/drivers/nvidia_drv.so
if [ ! -f "${GUEST_NVIDIA_XORG_DRV}" ]; then
    echo "WARNING: NVIDIA drivers not found in ${GUEST_NVIDIA_XORG_DRV}, if you have an nvidia GPU, this might not work."
fi
