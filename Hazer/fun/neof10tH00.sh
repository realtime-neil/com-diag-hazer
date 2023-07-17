#!/bin/bash
# Copyright 2023 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# I'm using an Ardusimple SimpleGNSS board with a
# u-blox NEO-F10T module. This is the first GNSS
# device I've used that implements the NMEA 0183 4.11
# specification. It is also the first generation 10
# u-blox device I've used. N.B. the labeling of the PVT
# (1PPS) and POWER LEDs are reversed on this version
# of the SimpleGNSS board.
# WORK IN PROGRESS

PROGRAM=$(basename ${0})
DEVICE=${1:-"/dev/ttyUSB0"}
RATE=${2:-38400}
ONEPPS=${3:-18}
STROBE=${4:-16}

SAVDIR=${COM_DIAG_HAZER_SAVDIR:-$(readlink -e $(dirname ${0})/..)/tmp}
mkdir -p ${SAVDIR}

ERRFIL="${SAVDIR}/${PROGRAM}.err"
mkdir -p $(dirname ${ERRFIL})
exec 2>>${ERRFIL}

OUTFIL="${SAVDIR}/${PROGRAM}.out"
mkdir -p $(dirname ${OUTFIL})

PIDFIL="${SAVDIR}/${PROGRAM}.pid"
mkdir -p $(dirname ${PIDFIL})

# LSTFIL="${SAVDIR}/${PROGRAM}.lst"
# mkdir -p $(dirname ${LSTFIL})
# -L ${LSTFIL}

# DATFIL="${SAVDIR}/${PROGRAM}.dat"
# mkdir -p $(dirname ${DATFIL})
# -C ${DATFIL}

. $(readlink -e $(dirname ${0})/../bin)/setup

# UBX-MON-VER [0]
# (Below from <https://www.ardusimple.com/wp-content/uploads/2023/05/simpleGNSS_FW301_1Hz_debug_message_off-GPSL5_on_00.txt>.)
# UBX-CFG-MSG [8] 0A 36 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0A 0B 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0A 37 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0A 09 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0A 02 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0A 06 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0A 2B 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0A 38 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0A 07 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0A 21 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0A 31 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0A 08 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 22 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 36 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 04 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 61 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 34 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 01 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 02 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 07 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 35 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 32 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 43 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 03 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 24 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 25 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 23 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 20 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 26 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 27 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 21 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 11 00 00 00 00 00 00
# UBX-CFG-MSG [8] 01 12 00 00 00 00 00 00
# UBX-CFG-MSG [8] 02 14 00 00 00 00 00 00
# UBX-CFG-MSG [8] 02 15 00 00 00 00 00 00
# UBX-CFG-MSG [8] 02 59 00 00 00 00 00 00
# UBX-CFG-MSG [8] 02 23 00 00 00 00 00 00
# UBX-CFG-MSG [8] 02 13 00 00 00 00 00 00
# UBX-CFG-MSG [8] 27 04 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0D 04 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0D 03 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0D 01 00 00 00 00 00 00
# UBX-CFG-MSG [8] 0D 06 00 00 00 00 00 00
# UBX-CFG-MSG [8] F0 00 01 01 00 00 01 00 NMEA-Standard-GGA
# UBX-CFG-MSG [8] F0 01 01 01 00 00 01 00 NMEA-Standard-GLL
# UBX-CFG-MSG [8] F0 02 01 01 00 00 01 00 NMEA-Standard-GSA
# UBX-CFG-MSG [8] F0 03 01 01 00 00 01 00 NMEA-Standard-GSV
# UBX-CFG-MSG [8] F0 04 01 01 00 00 01 00 NMEA-Standard-RMC
# UBX-CFG-MSG [8] F0 05 01 01 00 00 01 00 NMEA-Standard-VTG
# UBX-CFG-MSG [8] F0 06 00 00 00 00 00 00
# UBX-CFG-MSG [8] F0 07 00 00 00 00 00 00
# UBX-CFG-MSG [8] F0 08 01 01 00 00 01 00 NMEA-Standard-ZDA
# UBX-CFG-MSG [8] F0 09 00 00 00 00 00 00
# UBX-CFG-MSG [8] F0 0A 00 00 00 00 00 00
# UBX-CFG-MSG [8] F0 0D 00 00 00 00 00 00
# UBX-CFG-MSG [8] F1 00 00 00 00 00 00 00
# UBX-CFG-MSG [8] F1 03 00 00 00 00 00 00
# UBX-CFG-MSG [8] F1 04 00 00 00 00 00 00
# UBX-CFG-PRT [20] 00 00 00 00 84 00 00 00 00 00 00 00 03 00 03 00 00 00 00 00
# UBX-CFG-PRT [20] 01 00 00 00 C0 08 00 00 00 96 00 00 03 00 03 00 00 00 00 00
# UBX-CFG-PRT [20] 04 00 00 00 00 32 00 00 00 00 00 00 03 00 03 00 00 00 00 00
# (Below from u-blox F10 TIM Integration Description, p. 184.)
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-GPS_ENA 0x1031001f L - - GPS enable
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-GPS_L1CA_ENA 0x10310001 L - - GPS L1C/A
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-GPS_L5_ENA 0x10310004 L - - GPS L5
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-SBAS_ENA 0x10310020 L - - SBAS enable
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-SBAS_L1CA_ENA 0x10310005 L - - SBAS L1C/A
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-GAL_ENA 0x10310021 L - - Galileo enable
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-GAL_E1_ENA 0x10310007 L - - Galileo E1
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-GAL_E5A_ENA 0x10310009 L - - Galileo E5a
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-BDS_ENA 0x10310022 L - - BeiDou Enable
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-BDS_B1C_ENA 0x1031000f L - - BeiDou B1C
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-BDS_B2A_ENA 0x10310028 L - - BeiDou B2a
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-QZSS_ENA 0x10310024 L - - QZSS enable
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-QZSS_L1CA_ENA 0x10310012 L - - QZSS L1C/A
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-QZSS_L5_ENA 0x10310017 L - - QZSS L5
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-GLO_ENA 0x10310025 L - - GLONASS enable
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-NAVIC_ENA 0x10310026 L - - NavIC enable
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-NAVIC_L5_ENA 0x1031001d L - - NavIC L5

exec coreable gpstool \
	-D ${DEVICE} -b ${RATE} -8 -n -1 \
	-E -H ${OUTFIL} \
	-O ${PIDFIL} \
	-I ${ONEPPS} -p ${STROBE} \
	-t 10 -F 1 \
	-w 2 -x \
	-U '\xb5\x62\x0a\x04\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x36\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x0B\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x37\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x09\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x02\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x06\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x2B\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x38\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x07\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x21\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x31\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0A\x08\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x22\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x36\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x04\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x61\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x34\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x01\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x02\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x07\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x35\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x32\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x43\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x03\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x24\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x25\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x23\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x20\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x26\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x27\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x21\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x11\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x01\x12\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x02\x14\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x02\x15\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x02\x59\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x02\x23\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x02\x13\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x27\x04\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0D\x04\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0D\x03\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0D\x01\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\x0D\x06\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x00\x01\x01\x00\x00\x01\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x01\x01\x01\x00\x00\x01\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x02\x01\x01\x00\x00\x01\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x03\x01\x01\x00\x00\x01\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x04\x01\x01\x00\x00\x01\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x05\x01\x01\x00\x00\x01\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x06\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x07\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x08\x01\x01\x00\x00\x01\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x09\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x0A\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF0\x0D\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF1\x00\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF1\x03\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x01\x08\x00\xF1\x04\x00\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x00\x14\x00\x00\x00\x00\x00\x84\x00\x00\x00\x00\x00\x00\x00\x03\x00\x03\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x00\x14\x00\x01\x00\x00\x00\xC0\x08\x00\x00\x00\x96\x00\x00\x03\x00\x03\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x00\x14\x00\x04\x00\x00\x00\x00\x32\x00\x00\x00\x00\x00\x00\x03\x00\x03\x00\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x1f\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x01\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x04\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x20\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x05\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x21\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x07\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x09\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x22\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x0f\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x28\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x24\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x12\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x17\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x25\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x26\x00\x31\x10\x01' \
	-A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x1d\x00\x31\x10\x01' \
	< /dev/null > /dev/null

# This command was NAKed by the NEO-F10T.
# UBX-CFG-VALSET [9] V0 RAM 0 0 CFG-SIGNAL-GLO_L1_ENA 0x10310018 L - - GLONASS L1
# -A '\xb5\x62\x06\x8a\x09\x00\x00\x01\x00\x00\x18\x00\x31\x10\x01' \
