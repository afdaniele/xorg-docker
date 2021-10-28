#!/bin/bash

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------

set -eu

# make a fake tty
ln -s /dev/console "/dev/tty${VT}"

# launch dbus
mkdir -p /var/run/dbus/
dbus-daemon --system

# TODO: temporary
XORG_CONFIG=./assets/xorg.generic2.conf

# launching X
Xorg \
    -noreset \
    +extension GLX \
    +extension RENDER \
    -logfile "/var/log/${DISPLAY}.log" \
    -config "${XORG_CONFIG}" \
    -sharevts \
    -novtswitch \
    -keeptty \
    -verbose \
    -logverbose \
    "vt${VT}" \
    "${DISPLAY}" &
sleep 1

# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE
