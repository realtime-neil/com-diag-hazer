#!/bin/bash
# Copyright 2022 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# Configure and run the U-blox ZED-UBX-F9T as a high precision
# time and frequency reference in "survey-in" mode, with TP1
# emitting a 1PPS, and TP2 emitting a 10MHz square wave. This
# is part of the "Metronome" sub-project.
# THIS IS A WORK IN PROGRESS.

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

# UBX-CFG-VALSET [4] V1 Flash Start 0x00

# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TMODE-MODE SURVEY_IN
# UBX-CFG-VALSET [12] V1 Flash Continue 0x00 CFG-TMODE-SVIN_MIN_DUR 300 (@sec = 5min)
# UBX-CFG-VALSET [12] V1 Flash Continue 0x00 CFG-TMODE-SVIN_ACC_LIMIT 250 (@0.1mm = 2.5cm = ~1in)

# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-PULSE_DEF 1 (frequency)
# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-PULSE_LENGTH_DEF 0 (ratio)

# UBX-CFG-VALSET [12] V1 Flash Continue 0x00 CFG-TP-FREQ_TP1 1 (Hz)
# UBX-CFG-VALSET [12] V1 Flash Continue 0x00 CFG-TP-FREQ_LOCK_TP1 1 (Hz)
# UBX-CFG-VALSET [12] V1 Flash Continue 0x00 CFG-TP-DUTY_TP1 0.5 (%)
# UBX-CFG-VALSET [12] V1 Flash Continue 0x00 CFG-TP-DUTY_LOCK_TP1 0.5 (%)
# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-TIMEGRID_TP1 1 (GPS)
# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-ALIGN_TO_TOW_TP1 1
# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-USE_LOCKED_TP1 1
# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-POL_TP1 1
# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-TP1_ENA 1 ("Must be set for frequency-time products.")

# UBX-CFG-VALSET [12] V1 Flash Continue 0x00 CFG-TP-FREQ_TP2 10 000 000 (Hz)
# UBX-CFG-VALSET [12] V1 Flash Continue 0x00 CFG-TP-FREQ_LOCK_TP2 10 000 000 (Hz)
# UBX-CFG-VALSET [12] V1 Flash Continue 0x00 CFG-TP-DUTY_TP2 0.5 (%)
# UBX-CFG-VALSET [12] V1 Flash Continue 0x00 CFG-TP-DUTY_LOCK_TP2 0.5 (%)
# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-TIMEGRID_TP2 1 (GPS)
# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-ALIGN_TO_TOW_TP2 1
# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-USE_LOCKED_TP2 1
# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-POL_TP2 1
# UBX-CFG-VALSET [9] V1 Flash Continue 0x00 CFG-TP-TP2_ENA 1

# UBX-CFG-VALSET [4] V1 Flash Apply 0x00

# UBX-CFG-RST [4] coldstart hardwareshutdownreset

# exit

exec coreable gpstool \
    -H ${OUTFIL} -F 1 -t 10 \
    -O ${PIDFIL} \
    -N ${FIXFIL} \
    -D ${DEVICE} -b ${RATE} -8 -n -1 \
    -x \
    -U '\xb5\x62\x0a\x04\x00\x00' \
    \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  4)"'\x01\x04\x01\x00' \
    \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x01\x00\x03\x20'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2 12)"'\x01\x04\x02\x00\x10\x00\x03\x40'"$(ubxval -4 300)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2 12)"'\x01\x04\x02\x00\x11\x00\x03\x40'"$(ubxval -4 250)" \
    \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x20\x05\x00\x23'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x20\x05\x00\x30'"$(ubxval -1 0)" \
    \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2 12)"'\x01\x04\x02\x00\x40\x05\x00\x24'"$(ubxval -4 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2 12)"'\x01\x04\x02\x00\x40\x50\x00\x25'"$(ubxval -4 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2 16)"'\x01\x04\x02\x00\x50\x05\x00\x2a'"$(ubxval -D 0.5)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2 16)"'\x01\x04\x02\x00\x50\x05\x00\x2b'"$(ubxval -D 0.5)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x20\x05\x00\x0c'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x10\x05\x00\x0a'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x10\x05\x00\x09'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x10\x05\x00\x0b'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x50\x05\x00\x2b'"$(ubxval -1 1)" \
    \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2 12)"'\x01\x04\x02\x00\x40\x05\x00\x26'"$(ubxval -4 10000000)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2 12)"'\x01\x04\x02\x00\x50\x05\x00\x27'"$(ubxval -4 10000000)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2 16)"'\x01\x04\x02\x00\x50\x05\x00\x2c'"$(ubxval -D 0.5)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2 16)"'\x01\x04\x02\x00\x50\x05\x00\x2d'"$(ubxval -D 0.5)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x20\x05\x00\x17'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x10\x05\x00\x15'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x10\x05\x00\x14'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x10\x05\x00\x16'"$(ubxval -1 1)" \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  9)"'\x01\x04\x02\x00\x10\x05\x00\x12'"$(ubxval -1 1)" \
    \
    -A '\xb5\x62\x06\x8a'"$(ubxval -2  4)"'\x01\x04\x03\x00' \
    \
    -U '\xb5\x62\x06\x04'"$(ubxval -2 4)"'\xff\xff\x04\x00' \
    -U '' \
    < /dev/null 1> /dev/null

#####

# UBX-CFG-TP5 [32] 1 1 0x0000 0[2] 0[2] 10[4] 10[4] 5[4] 5[4] 0[4] 0x2077[4]

#    -A '\xb5\x62\x06\x31'"$(ubxval -2 32)$(ubxval -1 1)$(ubxval -1 1)"'\x00\x00'"$(ubxval -2 0)$(ubxval -2 0)$(ubxval -4 10000000)$(ubxval -4 10000000)$(ubxval -4 5)$(ubxval -4 5)$(ubxval -4 0)$(ubxval -4 0x247f)" \

#####

# UBX-CFG-TP5 [32] 0 1 0x0000 0[2] 0[2] 1,000,000[4] 1,000,000[4] 100,000[4] 100,000[4] 0[4] 0x2477[4]

#    -A '\xb5\x62\x06\x31'"$(ubxval -2 32)$(ubxval -1 0)$(ubxval -1 1)"'\x00\x00'"$(ubxval -2 0)$(ubxval -2 0)$(ubxval -4 1000000)$(ubxval -4 1000000)$(ubxval -4 100000)$(ubxval -4 100000)$(ubxval -4 50)$(ubxval -4 0x2477)" \

#####

