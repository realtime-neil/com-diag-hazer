#!/bin/bash
# Copyright 2023 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# usage: gps18xpcbinary [ DEVICE [ SLOW [ FAST ] ] ]
# THIS IS A WORK IN PROGRESS
# Script for the Garmin GPS-18x PC; this is the unit with the DB9 RS-232
# connector and the cigarette lighter socket power plug. It places the
# device in binary output mode and thenresets it.
# REFERENCES: Garmin, GPS 18x Tech Spec, Rev. D, 4.1.4, p. 14

PROGRAM=$(basename ${0})
DEVICE=${1:-"/dev/ttyUSB0"}
SLOW=${2:-"4800"}
FAST=${3:-"9600"}

ERRFIL=$(readlink -e $(dirname ${0})/..)/tmp/gps18xpc.err
mkdir -p $(dirname ${ERRFIL})
cp /dev/null ${ERRFIL}
exec 2>>${ERRFIL}

. $(readlink -e $(dirname ${0})/../bin)/setup

coreable gpstool -D ${DEVICE} -b ${SLOW} -8 -n -1 -E \
	-W '$PGRMC1,1,2,,,,,2,W,N,,,,1,,1' \
	-W '$PGRMI,,,,,,,R' \
	-W ''

exec coreable gpstool -D ${DEVICE} -b ${FAST} -8 -n -1 -E
