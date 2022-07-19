#!/bin/bash
# Copyright 2022 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# Configure and run the U-blox ZED-UBX-F9T as a high precision
# time and frequency reference in "survey-in" mode.

SAVDIR=${COM_DIAG_HAZER_SAVDIR:-$(readlink -e $(dirname ${0})/..)/tmp}

PROGRAM=$(basename ${0})
DEVICE=${1:-"/dev/ttyACM0"}
RATE=${2:-38400}
FIXFIL=${3-"${SAVDIR}/${PROGRAM}.fix"}
ERRFIL=${4-"${SAVDIR}/${PROGRAM}.err"}
OUTFIL=${5-"${SAVDIR}/${PROGRAM}.out"}
PIDFIL=${6-"${SAVDIR}/${PROGRAM}.pid"}

mkdir -p $(dirname ${FIXFIL})
mkdir -p $(dirname ${ERRFIL})
mkdir -p $(dirname ${OUTFIL})
mkdir -p $(dirname ${PIDFIL})

cp /dev/null ${ERRFIL}
exec 2>>${ERRFIL}

. $(readlink -e $(dirname ${0})/../bin)/setup

# UBX-MON-VER [0]

# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TMODE-MODE SURVEY_IN
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TMODE-SVIN_MIN_DUR 300 (@sec = 5min)
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TMODE-SVIN_ACC_LIMIT 250 (@0.1mm = 2.5cm = ~1in)

# UBX-CFG-VALSET [9] v0 RAM 0 0 CFG-TP-PULSE_DEF 0 (period)
# UBX-CFG-VALSET [9] v0 RAM 0 0 CFG-TP-PULSE_LENGTH_DEF 1 (length)

# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-TP1_ENA 0
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TP-PERIOD_TP1 1 000 000 (us)
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TP-LEN_TP1 100 000 (us)
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-TIMEGRID_TP1 1 (GPS)
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-ALIGN_TO_TOW_TP1 1
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-USE_LOCKED_TP1 1
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-POL_TP1 1
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TP-PERIOD_LOCK_TP1 100 000 (us)
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TP-LEN_LOCK_TP1 100 000 (us)
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-TP1_ENA 1

# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-TP2_ENA 0
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TP-PERIOD_TP2 1 000 000 (us)
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TP-LEN_TP2 100 000 (us)
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-TIMEGRID_TP2 1 (GPS)
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-ALIGN_TO_TOW_TP2 0
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-USE_LOCKED_TP2 1
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-POL_TP2 1
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TP-PERIOD_LOCK_TP2 100 000 (us)
# UBX-CFG-VALSET [12] V0 RAM 0 0 CFG-TP-LEN_LOCK_TP2 100 000 (us)
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-TP-TP2_ENA 1

exec coreable gpstool \
    -H ${OUTFIL} -F 1 -t 10 \
    -O ${PIDFIL} \
    -N ${FIXFIL} \
    -D ${DEVICE} -b ${RATE} -8 -n -1 \
    -x \
    -U '\xb5\x62\x0a\x04\x00\x00' \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x01\x00\x03\x20'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x10\x00\x03\x40'"$(ubxval -4 300)" \
    -A '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x11\x00\x03\x40'"$(ubxval -4 250)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x20\x05\x00\x23'"$(ubxval -1 0)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x20\x05\x00\x30'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x10\x05\x00\x07'"$(ubxval -1 0)" \
    -A '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x40\x05\x00\x02'"$(ubxval -4 1000000)" \
    -A '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x40\x05\x00\x04'"$(ubxval -4 100000)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x20\x05\x00\x0c'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x10\x05\x00\x0a'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x10\x05\x00\x09'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x10\x05\x00\x0b'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x40\x05\x00\x03'"$(ubxval -4 1000000)" \
    -A '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x40\x05\x00\x05'"$(ubxval -4 100000)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x10\x05\x00\x07'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x10\x05\x00\x12'"$(ubxval -1 0)" \
    -A '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x40\x05\x00\x0d'"$(ubxval -4 1000000)" \
    -A '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x40\x05\x00\x0f'"$(ubxval -4 100000)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x20\x05\x00\x17'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x10\x05\x00\x15'"$(ubxval -1 0)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x10\x05\x00\x14'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x10\x05\x00\x16'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x40\x05\x00\x03'"$(ubxval -4 1000000)" \
    -A '\xb5\x62\x06\x8a\x0c\x00\x00\x01\x00\x00\x40\x05\x00\x10'"$(ubxval -4 100000)" \
    -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x10\x05\x00\x12'"$(ubxval -1 1)" \
    < /dev/null 1> /dev/null
