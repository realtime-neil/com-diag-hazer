#!/bin/bash
# Copyright 2023 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# usage: gps18xusb2cpo [ DEVICE [ RATE ] ]
# Script for the Garmin GPS-18x USB; this is the unit with the USB connection.
# It places the device in CPO (binary) output mode, then resets it, and then
# exits.
# Assumes the device is in NMEA mode.
# Note that when in NMEA mode the device operate at 4800 BPS, and when
# in CPO (binary) mode the device at operates 9600 BPS.
# REFERENCES: Garmin, GPS 18x Tech Spec, Rev. D, 4.1.4, p. 14

PROGRAM=$(basename ${0})
DEVICE=${1:-"/dev/ttyACM0"}
RATE=${2:-"4800"}

ERRFIL=$(readlink -e $(dirname ${0})/..)/tmp/${PROGRAM}.err
mkdir -p $(dirname ${ERRFIL})
exec 2>>${ERRFIL}

. $(readlink -e $(dirname ${0})/../bin)/setup

coreable gpstool -D ${DEVICE} -b ${RATE} -8 -n -1 -E \
	-W '$PGRMO,GPALM,1' \
	-W '$PGRMC1,1,2,,,,,2,W,N,,,,1,,1' \
	-W '$PGRMI,,,,,,,R' \
	-W ''
