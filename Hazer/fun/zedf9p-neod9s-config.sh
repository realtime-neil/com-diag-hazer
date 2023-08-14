#!/bin/bash
# Copyright 2023 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# This script configures the UBX-NEO-D9S and the UBX-ZED-F9P.
# By default it uses the configuration script for the Nicker
# project containing the appropriate commands for the U.S.
# region.

SAVDIR=${COM_DIAG_HAZER_SAVDIR:-$(readlink -e $(dirname ${0})/..)/tmp}
CFGFIL=${COM_DIAG_HAZER_CFGFIL:-"${HOME}/com_diag_nicker_us.sh"}

PGMNAM=$(basename ${0})
FILNAM=${PGMNAM%%-*}
LOCDEV=${1:-"/dev/ttyACM0"}
LOCBPS=${2:-38400}
CORDEV=${3:-"/dev/ttyACM1"}
CORBPS=${4:-9600}
ERRFIL=${5:-"${SAVDIR}/${FILNAM}.err"}

. $(readlink -e $(dirname ${0})/../bin)/setup

mkdir -p $(dirname ${ERRFIL})

cp /dev/null ${ERRFIL}
exec 2>>${ERRFIL}

#####
# SOURCE THE CONFIGURATION SCRIPT.
#####

. ${CFGFIL}

#####
# CONFIGURE THE UBX-NEO-D9S INMARSAT RECEIVER.
#####

MESSAGE="${PGMNAM}: Configuring UBX-NEO-D9S ${CORDEV} ${CORBPS}"
log -I -N ${PGMNAM} -n "${MESSAGE}"
echo "${MESSAGE}"

OPTIONS=""
for OPTION in ${UBX_NEO_D9S}; do
    OPTIONS="${OPTIONS} ${OPTION}"
done

# UBX-VAL-SET [ 9] RAM: CFG-USART2OUTPROT-UBX=1
# UBX-VAL-SET [ 9] RAM: CFG-USART2-BAUDRATE=38400
# : (imported options) :

eval gpstool \
    -R \
    -D ${CORDEV} -b ${CORBPS} -8 -n -1 \
    -w 5 -x \
    -A '\\xb5\\x62\\x06\\x8a\\x09\\x00\\x00\\x01\\x00\\x00\\x01\\x00\\x76\\x10\\x01' \
    -A '\\xb5\\x62\\x06\\x8a\\x0c\\x00\\x00\\x01\\x00\\x00\\x01\\x00\\x53\\x40\\x00\\x96\\x00\\x00' \
    ${OPTIONS} \
    -U \"\" \
    < /dev/null

#####
# CONFIGURE THE UBX-ZED-F9P GNSS RECEIVER.
#####

MESSAGE="${PGMNAM}: Configuring UBX-ZED-F9P ${LOCDEV} ${LOCBPS}"
log -I -N ${PGMNAM} -n "${MESSAGE}"
echo "${MESSAGE}"

OPTIONS=""
for OPTION in ${UBX_ZED_F9P}; do
    OPTIONS="${OPTIONS} ${OPTION}"
done

# UBX-CFG-MSG [ 3] UBX-NAV-HPPOSLLH=1
# UBX-VAL-SET [ 9] v0 RAM: CFG-SPARTN-USE_SOURCE=1 (LBAND)
# UBX-VAL-SET [ 9] v0 RAM: CFG-USART2INPROT-UBX=1
# : (imported options) :
# UBX-RXM-SPARTNKEY [ 0]

eval gpstool \
    -R \
    -D ${LOCDEV} -b ${LOCBPS} -8 -n -1 \
    -w 5 -x \
    -U '\\xb5\\x62\\x06\\x01\\x03\\x00\\x01\\x14\\x01' \
    -U '\\xb5\\x62\\x06\\x8a\\x09\\x00\\x00\\x01\\x00\\x00\\x01\\x00\\xa7\\x20\\x01' \
    -U '\\xb5\\x62\\x06\\x8a\\x09\\x00\\x00\\x01\\x00\\x00\\x01\\x00\\x75\\x10\\x01' \
    ${OPTIONS} \
    -U '\\xb5\\x62\\x02\\x36\\x00\\x00' \
    -U \"\" \
    < /dev/null
