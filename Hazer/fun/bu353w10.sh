#!/bin/bash
# Copyright 2018 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer

# This script is specific to the GlobalSat BU-353W10. It is mostly
# the same as the script for the Navlocate GR-803G (with which it
# shares the use of the U-blox 8 chipset). But it sends two
# proprietary sentences to the BU-353W10 to cause it to [1] emit
# the satellite view (GSV) every second, and [2] emit the VTG
# sentence containing the course over ground (COG) and speed
# over ground (SOG) values every second, something the GR-803G
# does, but which the BU-353W10 does not right out of the box.

PROGRAM=$(basename ${0})
DEVICE=${1:-"/dev/ttyACM0"}
RATE=${2:-9600}

. $(readlink -e $(dirname ${0})/../bin)/setup

DIR=$(readlink -e $(dirname ${0})/..)/log
mkdir -p ${DIR}

eval coreable gpstool -D ${DEVICE} -b ${RATE} -8 -n -1 -E -t 10 -W '\$PUBX,40,GSV,0,0,0,1,0,0' -W '\$PUBX,40,VTG,0,0,0,1,0,0' 2>> ${DIR}/${PROGRAM}.log