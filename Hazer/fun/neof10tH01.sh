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
# of the SimpleGNSS board. This script uses version 01
# of the Ardusimple configuration file.

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
# (Below adapted from <https://www.ardusimple.com/wp-content/uploads/2023/07/simpleGNSS_FW301_1Hz_debug_message_off-GPSL5_on-01.txt>.)
# UBX-CFG-VALSET - 06 8B 44 01 01 01 00 00 01 00 01 10 00 12 00 03 10 01 13 00 03 10 01 09 00 04 10 01 07 00 05 10 01 08 00 05 10 01 09 00 05 10 01 0A 00 05 10 01 0B 00 05 10 01 05 00 0B 10 01 06 00 0B 10 01 07 00 0B 10 01 12 00 11 10 00 13 00 11 10 00 14 00 11 10 01 15 00 11 10 01 16 00 11 10 01 18 00 11 10 01 19 00 11 10 01 1B 00 11 10 00 1D 00 11 10 01 25 00 11 10 00 46 00 11 10 01 52 00 11 10 00 53 00 11 10 00 61 00 11 10 00 81 00 11 10 00 82 00 11 10 00 83 00 11 10 00 52 00 14 10 00 01 00 17 10 00 02 00 17 10 00 01 00 25 10 01 01 00 31 10 01 04 00 31 10 01 05 00 31 10 01 07 00 31 10 01 09 00 31 10 01 0D 00 31 10 00 0F 00 31 10 01 12 00 31 10 01 17 00 31 10 00 18 00 31 10 00 1D 00 31 10 00 1F 00 31 10 01 20 00 31 10 01 21 00 31 10 01 22 00 31 10 01 24 00 31 10 01 25 00 31 10 01 26 00 31 10 01 28 00 31 10 01 01 00 32 10 00 02 00 32 10 00 03 00 32 10 00 04 00 32 10 00 01 00 33 10 00 02 00 33 10 00 03 00 33 10 00 11 00 33 10 00 01 00 34 10 00 02 00 34 10 00 03 00 34 10 01 04 00 34 10 00
# UBX-CFG-VALSET - 06 8B 44 01 01 01 40 00 11 00 34 10 00 14 00 34 10 01 01 00 35 10 00 02 00 35 10 00 03 00 35 10 00 04 00 35 10 00 02 00 36 10 00 03 00 36 10 00 04 00 36 10 00 05 00 36 10 00 07 00 36 10 01 02 00 37 10 00 03 00 37 10 00 90 00 37 10 00 91 00 37 10 00 01 00 38 10 01 02 00 51 10 00 03 00 51 10 00 04 00 51 10 00 05 00 52 10 01 06 00 52 10 00 07 00 52 10 00 02 00 64 10 00 03 00 64 10 00 04 00 64 10 00 05 00 64 10 00 06 00 64 10 00 07 00 64 10 00 01 00 71 10 01 02 00 71 10 01 01 00 72 10 01 02 00 72 10 01 01 00 73 10 01 02 00 73 10 01 01 00 74 10 01 02 00 74 10 01 01 00 79 10 01 02 00 79 10 01 01 00 7A 10 01 02 00 7A 10 01 01 00 81 10 00 02 00 81 10 00 05 00 81 10 00 01 00 82 10 00 02 00 82 10 00 05 00 82 10 00 01 00 85 10 00 02 00 85 10 00 05 00 85 10 00 03 00 93 10 00 04 00 93 10 01 05 00 93 10 00 06 00 93 10 00 11 00 93 10 00 12 00 93 10 00 13 00 93 10 00 15 00 93 10 00 16 00 93 10 00 17 00 93 10 00 18 00 93 10 00 21 00 93 10 00 22 00 93 10 00 23 00 93 10 00 24 00 93 10 00
# UBX-CFG-VALSET - 06 8B 44 01 01 01 80 00 25 00 93 10 00 26 00 93 10 00 01 00 A1 10 00 02 00 A1 10 00 03 00 A1 10 01 01 00 A2 10 00 02 00 A2 10 00 07 00 A3 10 01 08 00 A3 10 00 09 00 A3 10 01 0A 00 A3 10 00 0B 00 A3 10 00 0C 00 A3 10 00 0D 00 A3 10 00 0E 00 A3 10 00 0F 00 A3 10 00 10 00 A3 10 00 11 00 A3 10 01 13 00 A3 10 00 17 00 A3 10 01 19 00 A3 10 00 20 00 A3 10 00 21 00 A3 10 01 29 00 A3 10 00 2C 00 A3 10 00 2E 00 A3 10 00 2F 00 A3 10 00 30 00 A3 10 01 31 00 A3 10 00 32 00 A3 10 01 33 00 A3 10 00 34 00 A3 10 01 35 00 A3 10 00 47 00 A3 10 01 58 00 A3 10 00 59 00 A3 10 00 5A 00 A3 10 00 5B 00 A3 10 00 5C 00 A3 10 00 5D 00 A3 10 00 5E 00 A3 10 00 02 00 C6 10 00 01 00 C7 10 00 02 00 C7 10 00 09 00 F6 10 00 14 00 F6 10 01 35 00 F6 10 01 36 00 F6 10 01 37 00 F6 10 01 38 00 F6 10 01 3A 00 F6 10 01 3B 00 F6 10 01 3C 00 F6 10 01 3D 00 F6 10 01 3E 00 F6 10 01 3F 00 F6 10 01 40 00 F6 10 01 41 00 F6 10 01 44 00 F6 10 01 46 00 F6 10 01 47 00 F6 10 01 48 00 F6 10 01 49 00 F6 10 01 4A 00 F6 10 01
# UBX-CFG-VALSET - 06 8B 44 01 01 01 C0 00 4B 00 F6 10 01 4C 00 F6 10 01 50 00 F6 10 01 51 00 F6 10 01 52 00 F6 10 01 5A 00 F6 10 01 11 00 01 20 00 21 00 01 20 00 31 00 01 20 00 41 00 01 20 00 51 00 01 20 00 61 00 01 20 00 71 00 01 20 00 81 00 01 20 00 91 00 01 20 00 A1 00 01 20 00 B1 00 01 20 00 C1 00 01 20 00 D1 00 01 20 00 E1 00 01 20 00 01 00 03 20 00 02 00 03 20 00 06 00 03 20 00 07 00 03 20 00 08 00 03 20 00 0C 00 03 20 00 0D 00 03 20 00 0E 00 03 20 00 14 00 03 20 00 0C 00 05 20 01 23 00 05 20 00 30 00 05 20 01 35 00 05 20 01 01 00 0B 20 03 02 00 0B 20 0A 03 00 0B 20 28 04 00 0B 20 05 11 00 11 20 03 1A 00 11 20 12 1C 00 11 20 00 20 00 11 20 64 21 00 11 20 02 22 00 11 20 00 23 00 11 20 00 24 00 11 20 01 42 00 11 20 02 43 00 11 20 03 44 00 11 20 01 45 00 11 20 01 47 00 11 20 00 51 00 11 20 00 A1 00 11 20 01 A2 00 11 20 20 A3 00 11 20 09 A4 00 11 20 0A AA 00 11 20 00 AB 00 11 20 00 C4 00 11 20 3C 03 00 21 20 01 38 00 25 20 00 05 00 34 20 0A 07 00 34 20 37 21 00 34 20 00 22 00 34 20 02
# UBX-CFG-VALSET - 06 8B 44 01 01 01 00 01 01 00 51 20 84 09 00 51 20 01 02 00 52 20 01 03 00 52 20 00 04 00 52 20 00 08 00 52 20 00 09 00 52 20 01 01 00 64 20 32 08 00 64 20 00 09 00 64 20 00 06 00 91 20 00 07 00 91 20 00 0A 00 91 20 00 10 00 91 20 00 11 00 91 20 00 14 00 91 20 00 15 00 91 20 00 16 00 91 20 00 19 00 91 20 00 1A 00 91 20 00 1B 00 91 20 00 1E 00 91 20 00 24 00 91 20 00 25 00 91 20 00 28 00 91 20 00 29 00 91 20 00 2A 00 91 20 00 2D 00 91 20 00 38 00 91 20 00 39 00 91 20 00 3C 00 91 20 00 3D 00 91 20 00 3E 00 91 20 00 41 00 91 20 00 42 00 91 20 00 43 00 91 20 00 46 00 91 20 00 47 00 91 20 00 48 00 91 20 00 4B 00 91 20 00 4C 00 91 20 00 4D 00 91 20 00 50 00 91 20 00 51 00 91 20 00 52 00 91 20 00 55 00 91 20 00 56 00 91 20 00 57 00 91 20 00 5A 00 91 20 00 5B 00 91 20 00 5C 00 91 20 00 5F 00 91 20 00 60 00 91 20 00 61 00 91 20 00 64 00 91 20 00 65 00 91 20 00 66 00 91 20 00 69 00 91 20 00 6A 00 91 20 00 6B 00 91 20 00 6E 00 91 20 00 83 00 91 20 00 84 00 91 20 00 87 00 91 20 00
# UBX-CFG-VALSET - 06 8B 44 01 01 01 40 01 92 00 91 20 00 93 00 91 20 00 96 00 91 20 00 97 00 91 20 00 98 00 91 20 00 9B 00 91 20 00 A6 00 91 20 00 A7 00 91 20 00 AA 00 91 20 00 AB 00 91 20 01 AC 00 91 20 01 AF 00 91 20 01 B0 00 91 20 01 B1 00 91 20 01 B4 00 91 20 01 B5 00 91 20 00 B6 00 91 20 00 B9 00 91 20 00 BA 00 91 20 01 BB 00 91 20 01 BE 00 91 20 01 BF 00 91 20 01 C0 00 91 20 01 C3 00 91 20 01 C4 00 91 20 01 C5 00 91 20 01 C8 00 91 20 01 C9 00 91 20 01 CA 00 91 20 01 CD 00 91 20 01 CE 00 91 20 00 CF 00 91 20 00 D2 00 91 20 00 D3 00 91 20 00 D4 00 91 20 00 D7 00 91 20 00 D8 00 91 20 01 D9 00 91 20 01 DC 00 91 20 01 DD 00 91 20 00 DE 00 91 20 00 E1 00 91 20 00 EC 00 91 20 00 ED 00 91 20 00 F0 00 91 20 00 F1 00 91 20 00 F2 00 91 20 00 F5 00 91 20 00 F6 00 91 20 00 F7 00 91 20 00 FA 00 91 20 00 19 01 91 20 00 1A 01 91 20 00 1D 01 91 20 00 1E 01 91 20 00 1F 01 91 20 00 22 01 91 20 00 2D 01 91 20 00 2E 01 91 20 00 31 01 91 20 00 37 01 91 20 00 38 01 91 20 00 3B 01 91 20 00 55 01 91 20 00
# UBX-CFG-VALSET - 06 8B 44 01 01 01 80 01 56 01 91 20 00 59 01 91 20 00 5F 01 91 20 00 60 01 91 20 00 63 01 91 20 00 78 01 91 20 00 79 01 91 20 00 7C 01 91 20 00 7D 01 91 20 00 7E 01 91 20 00 81 01 91 20 00 82 01 91 20 00 83 01 91 20 00 86 01 91 20 00 87 01 91 20 00 88 01 91 20 00 8B 01 91 20 00 8C 01 91 20 00 8D 01 91 20 00 90 01 91 20 00 91 01 91 20 00 92 01 91 20 00 95 01 91 20 00 96 01 91 20 00 97 01 91 20 00 9A 01 91 20 00 9B 01 91 20 00 9C 01 91 20 00 9F 01 91 20 00 A0 01 91 20 00 A1 01 91 20 00 A4 01 91 20 00 A5 01 91 20 00 A6 01 91 20 00 A9 01 91 20 00 AA 01 91 20 00 AB 01 91 20 00 AE 01 91 20 00 AF 01 91 20 00 B0 01 91 20 00 B3 01 91 20 00 B4 01 91 20 00 B5 01 91 20 00 B8 01 91 20 00 B9 01 91 20 00 BA 01 91 20 00 BD 01 91 20 00 C8 01 91 20 00 C9 01 91 20 00 CC 01 91 20 00 CD 01 91 20 00 CE 01 91 20 00 D1 01 91 20 00 D2 01 91 20 00 D3 01 91 20 00 D6 01 91 20 00 DC 01 91 20 00 DD 01 91 20 00 E0 01 91 20 00 E1 01 91 20 00 E2 01 91 20 00 E5 01 91 20 00 E6 01 91 20 00 E7 01 91 20 00
# UBX-CFG-VALSET - 06 8B 44 01 01 01 C0 01 EA 01 91 20 00 F5 01 91 20 00 F6 01 91 20 00 F9 01 91 20 00 FF 01 91 20 00 00 02 91 20 00 03 02 91 20 00 04 02 91 20 00 05 02 91 20 00 08 02 91 20 00 09 02 91 20 00 0A 02 91 20 00 0D 02 91 20 00 0E 02 91 20 00 0F 02 91 20 00 12 02 91 20 00 13 02 91 20 00 14 02 91 20 00 17 02 91 20 00 18 02 91 20 00 19 02 91 20 00 1C 02 91 20 00 2C 02 91 20 00 2D 02 91 20 00 30 02 91 20 00 31 02 91 20 00 32 02 91 20 00 35 02 91 20 00 36 02 91 20 00 37 02 91 20 00 3A 02 91 20 00 3B 02 91 20 00 3C 02 91 20 00 3F 02 91 20 00 40 02 91 20 00 41 02 91 20 00 44 02 91 20 00 4A 02 91 20 00 4B 02 91 20 00 4E 02 91 20 00 54 02 91 20 00 55 02 91 20 00 58 02 91 20 00 5E 02 91 20 00 5F 02 91 20 00 62 02 91 20 00 90 02 91 20 00 91 02 91 20 00 94 02 91 20 00 A4 02 91 20 00 A5 02 91 20 00 A8 02 91 20 00 2C 03 91 20 00 2D 03 91 20 00 30 03 91 20 00 45 03 91 20 00 46 03 91 20 00 49 03 91 20 00 4A 03 91 20 00 4B 03 91 20 00 4E 03 91 20 00 4F 03 91 20 00 50 03 91 20 00 53 03 91 20 00
# UBX-CFG-VALSET - 06 8B 44 01 01 01 00 02 54 03 91 20 00 55 03 91 20 00 58 03 91 20 00 59 03 91 20 00 5A 03 91 20 00 5D 03 91 20 00 7C 03 91 20 00 7D 03 91 20 00 80 03 91 20 00 86 03 91 20 00 87 03 91 20 00 8A 03 91 20 00 8B 03 91 20 00 8C 03 91 20 00 8F 03 91 20 00 00 04 91 20 00 01 04 91 20 00 04 04 91 20 00 1A 04 91 20 00 1B 04 91 20 00 1E 04 91 20 00 30 04 91 20 00 31 04 91 20 00 34 04 91 20 00 35 04 91 20 00 36 04 91 20 00 39 04 91 20 00 40 04 91 20 00 41 04 91 20 00 44 04 91 20 00 50 04 91 20 00 51 04 91 20 00 54 04 91 20 00 55 04 91 20 00 56 04 91 20 00 59 04 91 20 00 65 04 91 20 00 66 04 91 20 00 69 04 91 20 00 80 04 91 20 00 81 04 91 20 00 84 04 91 20 00 85 04 91 20 00 86 04 91 20 00 89 04 91 20 00 90 04 91 20 00 91 04 91 20 00 94 04 91 20 00 95 04 91 20 00 96 04 91 20 00 99 04 91 20 00 00 05 91 20 00 01 05 91 20 00 04 05 91 20 00 05 05 91 20 00 06 05 91 20 00 09 05 91 20 00 15 05 91 20 00 16 05 91 20 00 19 05 91 20 00 25 05 91 20 00 26 05 91 20 00 29 05 91 20 00 30 05 91 20 00
# UBX-CFG-VALSET - 06 8B 44 01 01 01 40 02 31 05 91 20 00 34 05 91 20 00 35 05 91 20 00 36 05 91 20 00 39 05 91 20 00 40 05 91 20 00 41 05 91 20 00 44 05 91 20 00 45 05 91 20 00 46 05 91 20 00 49 05 91 20 00 50 05 91 20 00 51 05 91 20 00 54 05 91 20 00 55 05 91 20 00 56 05 91 20 00 59 05 91 20 00 60 05 91 20 00 61 05 91 20 00 64 05 91 20 00 65 05 91 20 00 66 05 91 20 00 69 05 91 20 00 90 05 91 20 00 91 05 91 20 00 94 05 91 20 00 00 06 91 20 00 01 06 91 20 00 04 06 91 20 00 34 06 91 20 00 35 06 91 20 00 38 06 91 20 00 52 06 91 20 00 53 06 91 20 00 56 06 91 20 00 57 06 91 20 00 58 06 91 20 00 5B 06 91 20 00 5C 06 91 20 00 5D 06 91 20 00 60 06 91 20 00 61 06 91 20 00 62 06 91 20 00 65 06 91 20 00 66 06 91 20 00 67 06 91 20 00 6A 06 91 20 00 70 06 91 20 00 71 06 91 20 00 74 06 91 20 00 7F 06 91 20 00 80 06 91 20 00 83 06 91 20 00 84 06 91 20 00 85 06 91 20 00 88 06 91 20 00 89 06 91 20 00 8A 06 91 20 00 8D 06 91 20 00 9D 06 91 20 00 9E 06 91 20 00 A1 06 91 20 00 A2 06 91 20 00 A3 06 91 20 00
# UBX-CFG-VALSET - 06 8B 47 01 01 01 80 02 A6 06 91 20 00 A7 06 91 20 00 A8 06 91 20 00 AB 06 91 20 00 C0 06 91 20 01 C1 06 91 20 01 C4 06 91 20 01 01 00 92 20 00 02 00 92 20 00 05 00 92 20 00 06 00 92 20 07 07 00 92 20 07 0A 00 92 20 07 01 00 93 20 2A 02 00 93 20 00 07 00 93 20 00 31 00 93 20 00 32 00 93 20 00 03 00 A2 20 00 05 00 A2 20 00 36 00 A3 20 07 37 00 A3 20 06 38 00 A3 20 05 51 00 A3 20 00 54 00 A3 20 00 55 00 A3 20 00 56 00 A3 20 00 57 00 A3 20 00 01 00 C5 20 14 02 00 C5 20 8C 01 00 C6 20 08 04 00 C6 20 00 06 00 C6 20 01 08 00 C6 20 00 0A 00 C6 20 01 0C 00 C6 20 00 0E 00 C6 20 01 10 00 C6 20 00 12 00 C6 20 01 14 00 C6 20 00 16 00 C6 20 01 18 00 C6 20 00 1A 00 C6 20 01 1C 00 C6 20 00 1E 00 C6 20 01 20 00 C6 20 00 22 00 C6 20 01 24 00 C6 20 00 26 00 C6 20 01 28 00 C6 20 00 2A 00 C6 20 01 2C 00 C6 20 00 2E 00 C6 20 01 30 00 C6 20 00 32 00 C6 20 01 03 00 C7 20 16 01 00 F6 20 00 39 00 F6 20 03 45 00 F6 20 09 53 00 F6 20 04 54 00 F6 20 08 10 00 01 30 00 00 20 00 01 30 00 00 30 00 01 30 00 00
# UBX-CFG-VALSET - 06 8B AA 01 01 01 C0 02 40 00 01 30 00 00 50 00 01 30 00 00 60 00 01 30 00 00 70 00 01 30 00 00 80 00 01 30 00 00 90 00 01 30 00 00 A0 00 01 30 00 00 B0 00 01 30 00 00 C0 00 01 30 00 00 D0 00 01 30 00 00 E0 00 01 30 00 00 01 00 02 30 64 00 01 00 05 30 32 00 17 00 11 30 C9 08 B1 00 11 30 FA 00 B2 00 11 30 FA 00 B3 00 11 30 64 00 B4 00 11 30 5E 01 B5 00 11 30 96 00 01 00 21 30 E8 03 02 00 21 30 01 00 3B 00 25 30 00 00 06 00 34 30 46 00 08 00 34 30 91 00 08 00 36 30 00 00 33 00 93 30 00 00 04 00 A2 30 00 00 3C 00 A3 30 F4 01 45 00 A3 30 B0 04 46 00 A3 30 E8 03 48 00 A3 30 00 00 05 00 C6 30 00 00 09 00 C6 30 00 00 0D 00 C6 30 00 00 11 00 C6 30 00 00 15 00 C6 30 00 00 19 00 C6 30 00 00 1D 00 C6 30 00 00 21 00 C6 30 00 00 25 00 C6 30 00 00 29 00 C6 30 00 00 2D 00 C6 30 00 00 31 00 C6 30 00 00 0A 00 F6 30 00 00 0B 00 F6 30 00 00 03 00 03 40 00 00 00 00 04 00 03 40 00 00 00 00 05 00 03 40 00 00 00 00 09 00 03 40 00 00 00 00 0A 00 03 40 00 00 00 00 0B 00 03 40 00 00 00 00 0F 00 03 40 00 00 00 00 10 00 03 40 00 00 00 00 11 00 03 40 00 00 00 00 02 00 05 40 40 42 0F 00 03 00 05 40 40 42 0F 00 04 00 05 40 00 00 00 00 05 00 05 40 A0 86 01 00 06 00 05 40 00 00 00 00 24 00 05 40 01 00 00 00 25 00 05 40 01 00 00 00 64 00 11 40 00 00 00 00 65 00 11 40 00 00 00 00 66 00 11 40 00 00 00 00
# UBX-CFG-VALSET - 06 8B 64 02 01 01 00 03 67 00 11 40 00 00 00 00 68 00 11 40 00 00 00 00 69 00 11 40 00 00 00 00 6A 00 11 40 00 00 00 00 C1 00 11 40 00 00 00 00 C2 00 11 40 10 27 00 00 D1 00 11 40 00 00 00 00 D2 00 11 40 00 00 00 00 D3 00 11 40 00 00 00 00 D8 00 11 40 00 75 12 00 D9 00 11 40 00 75 12 00 DA 00 11 40 80 3A 09 00 DB 00 11 40 80 3A 09 00 DC 00 11 40 80 3A 09 00 12 00 34 40 F0 F1 FF FF 13 00 34 40 30 2A 00 00 15 00 34 40 FF FF FF FF 01 00 52 40 00 96 00 00 28 00 A3 40 00 00 00 00 2A 00 A3 40 00 00 00 00 2B 00 A3 40 00 00 00 00 41 00 A3 40 00 00 00 00 42 00 A3 40 D0 07 00 00 43 00 A3 40 E8 03 00 00 44 00 A3 40 F4 01 00 00 52 00 A3 40 08 07 00 00 53 00 A3 40 00 00 00 00 01 00 A4 40 00 B0 71 0B 03 00 A4 40 00 B0 71 0B 04 00 A4 40 00 B0 71 0B 05 00 A4 40 00 B0 71 0B 07 00 A4 40 00 90 D0 03 08 00 A4 40 00 90 D0 03 0A 00 A4 40 00 D8 B8 05 0C 00 A4 40 00 24 F4 00 0D 00 A4 40 80 BA 8C 01 10 00 A4 40 00 B0 71 0B 11 00 A4 40 00 12 7A 00 01 00 A6 40 00 00 00 00 14 00 D0 40 31 00 00 00 2A 00 05 50 00 00 00 00 00 00 00 00 2B 00 05 50 00 00 00 00 00 00 24 40 62 00 11 50 00 00 00 40 A6 54 58 41 63 00 11 50 88 6D 74 96 1D A4 72 40 01 00 18 50 FF FF FF FF FF FF FF FF 02 00 18 50 FF FF FF FF FF FF FF FF 03 00 18 50 FF FF FF FF FF FF FF FF 04 00 18 50 FF FF FF FF FF FF FF FF 05 00 18 50 FF FF FF FF FF FF FF FF 06 00 18 50 FF FF FF FF FF FF FF FF 07 00 18 50 FF FF FF FF FF FF FF FF 08 00 18 50 FF FF FF FF FF FF FF FF 09 00 18 50 FF FF FF FF FF FF FF FF 0A 00 18 50 FF FF FF FF FF FF FF FF 0B 00 18 50 FF FF FF FF FF FF FF FF 0C 00 18 50 FF FF FF FF FF FF FF FF 0D 00 18 50 FF FF FF FF FF FF FF FF 0E 00 18 50 FF FF FF FF FF FF FF FF 0F 00 18 50 FF FF FF FF FF FF FF FF 10 00 18 50 FF FF FF FF FF FF FF FF 11 00 18 50 FF FF FF FF FF FF FF FF 12 00 18 50 FF FF FF FF FF FF FF FF 13 00 18 50 FF FF FF FF FF FF FF FF 14 00 18 50 FF FF FF FF FF FF FF FF
# UBX-CFG-VALSET - 06 8B 60 01 01 01 40 03 15 00 18 50 FF FF FF FF FF FF FF FF 16 00 18 50 FF FF FF FF FF FF FF FF 17 00 18 50 FF FF FF FF FF FF FF FF 18 00 18 50 FF FF FF FF FF FF FF FF 06 00 36 50 88 AB 03 00 00 00 00 00 49 00 A3 50 4E 45 4F 2D 46 31 30 54 07 00 C6 50 00 00 00 00 00 00 00 00 0B 00 C6 50 00 00 00 00 00 00 00 00 0F 00 C6 50 00 00 00 00 00 00 00 00 13 00 C6 50 00 00 00 00 00 00 00 00 17 00 C6 50 00 00 00 00 00 00 00 00 1B 00 C6 50 00 00 00 00 00 00 00 00 1F 00 C6 50 00 00 00 00 00 00 00 00 23 00 C6 50 00 00 00 00 00 00 00 00 27 00 C6 50 00 00 00 00 00 00 00 00 2B 00 C6 50 00 00 00 00 00 00 00 00 2F 00 C6 50 00 00 00 00 00 00 00 00 33 00 C6 50 00 00 00 00 00 00 00 00 04 00 C7 50 4E 6F 74 69 63 65 3A 20 05 00 C7 50 6E 6F 20 64 61 74 61 20 06 00 C7 50 73 61 76 65 64 21 00 00 07 00 C7 50 00 00 00 00 00 00 00 00 02 00 F6 50 00 00 00 00 00 00 00 00 03 00 F6 50 00 00 00 00 00 00 00 00 04 00 F6 50 00 00 00 00 00 00 00 00 05 00 F6 50 00 00 00 00 00 00 00 00 06 00 F6 50 00 00 00 00 00 00 00 00 07 00 F6 50 00 00 00 00 00 00 00 00 08 00 F6 50 00 00 00 00 00 00 00 00

exec coreable gpstool \
	-D ${DEVICE} -b ${RATE} -8 -n -1 \
	-E -H ${OUTFIL} \
	-O ${PIDFIL} \
	-I ${ONEPPS} -p ${STROBE} \
	-t 10 -F 1 \
	-w 2 -x \
	-U '\xb5\x62\x0a\x04\x00\x00' \
	-A '\xb5\x62\x06\x8A\x44\x01\x01\x01\x00\x00\x01\x00\x01\x10\x00\x12\x00\x03\x10\x01\x13\x00\x03\x10\x01\x09\x00\x04\x10\x01\x07\x00\x05\x10\x01\x08\x00\x05\x10\x01\x09\x00\x05\x10\x01\x0A\x00\x05\x10\x01\x0B\x00\x05\x10\x01\x05\x00\x0B\x10\x01\x06\x00\x0B\x10\x01\x07\x00\x0B\x10\x01\x12\x00\x11\x10\x00\x13\x00\x11\x10\x00\x14\x00\x11\x10\x01\x15\x00\x11\x10\x01\x16\x00\x11\x10\x01\x18\x00\x11\x10\x01\x19\x00\x11\x10\x01\x1B\x00\x11\x10\x00\x1D\x00\x11\x10\x01\x25\x00\x11\x10\x00\x46\x00\x11\x10\x01\x52\x00\x11\x10\x00\x53\x00\x11\x10\x00\x61\x00\x11\x10\x00\x81\x00\x11\x10\x00\x82\x00\x11\x10\x00\x83\x00\x11\x10\x00\x52\x00\x14\x10\x00\x01\x00\x17\x10\x00\x02\x00\x17\x10\x00\x01\x00\x25\x10\x01\x01\x00\x31\x10\x01\x04\x00\x31\x10\x01\x05\x00\x31\x10\x01\x07\x00\x31\x10\x01\x09\x00\x31\x10\x01\x0D\x00\x31\x10\x00\x0F\x00\x31\x10\x01\x12\x00\x31\x10\x01\x17\x00\x31\x10\x00\x18\x00\x31\x10\x00\x1D\x00\x31\x10\x00\x1F\x00\x31\x10\x01\x20\x00\x31\x10\x01\x21\x00\x31\x10\x01\x22\x00\x31\x10\x01\x24\x00\x31\x10\x01\x25\x00\x31\x10\x01\x26\x00\x31\x10\x01\x28\x00\x31\x10\x01\x01\x00\x32\x10\x00\x02\x00\x32\x10\x00\x03\x00\x32\x10\x00\x04\x00\x32\x10\x00\x01\x00\x33\x10\x00\x02\x00\x33\x10\x00\x03\x00\x33\x10\x00\x11\x00\x33\x10\x00\x01\x00\x34\x10\x00\x02\x00\x34\x10\x00\x03\x00\x34\x10\x01\x04\x00\x34\x10\x00' \
	-A '\xb5\x62\x06\x8A\x44\x01\x01\x01\x40\x00\x11\x00\x34\x10\x00\x14\x00\x34\x10\x01\x01\x00\x35\x10\x00\x02\x00\x35\x10\x00\x03\x00\x35\x10\x00\x04\x00\x35\x10\x00\x02\x00\x36\x10\x00\x03\x00\x36\x10\x00\x04\x00\x36\x10\x00\x05\x00\x36\x10\x00\x07\x00\x36\x10\x01\x02\x00\x37\x10\x00\x03\x00\x37\x10\x00\x90\x00\x37\x10\x00\x91\x00\x37\x10\x00\x01\x00\x38\x10\x01\x02\x00\x51\x10\x00\x03\x00\x51\x10\x00\x04\x00\x51\x10\x00\x05\x00\x52\x10\x01\x06\x00\x52\x10\x00\x07\x00\x52\x10\x00\x02\x00\x64\x10\x00\x03\x00\x64\x10\x00\x04\x00\x64\x10\x00\x05\x00\x64\x10\x00\x06\x00\x64\x10\x00\x07\x00\x64\x10\x00\x01\x00\x71\x10\x01\x02\x00\x71\x10\x01\x01\x00\x72\x10\x01\x02\x00\x72\x10\x01\x01\x00\x73\x10\x01\x02\x00\x73\x10\x01\x01\x00\x74\x10\x01\x02\x00\x74\x10\x01\x01\x00\x79\x10\x01\x02\x00\x79\x10\x01\x01\x00\x7A\x10\x01\x02\x00\x7A\x10\x01\x01\x00\x81\x10\x00\x02\x00\x81\x10\x00\x05\x00\x81\x10\x00\x01\x00\x82\x10\x00\x02\x00\x82\x10\x00\x05\x00\x82\x10\x00\x01\x00\x85\x10\x00\x02\x00\x85\x10\x00\x05\x00\x85\x10\x00\x03\x00\x93\x10\x00\x04\x00\x93\x10\x01\x05\x00\x93\x10\x00\x06\x00\x93\x10\x00\x11\x00\x93\x10\x00\x12\x00\x93\x10\x00\x13\x00\x93\x10\x00\x15\x00\x93\x10\x00\x16\x00\x93\x10\x00\x17\x00\x93\x10\x00\x18\x00\x93\x10\x00\x21\x00\x93\x10\x00\x22\x00\x93\x10\x00\x23\x00\x93\x10\x00\x24\x00\x93\x10\x00' \
	-A '\xb5\x62\x06\x8A\x44\x01\x01\x01\x80\x00\x25\x00\x93\x10\x00\x26\x00\x93\x10\x00\x01\x00\xA1\x10\x00\x02\x00\xA1\x10\x00\x03\x00\xA1\x10\x01\x01\x00\xA2\x10\x00\x02\x00\xA2\x10\x00\x07\x00\xA3\x10\x01\x08\x00\xA3\x10\x00\x09\x00\xA3\x10\x01\x0A\x00\xA3\x10\x00\x0B\x00\xA3\x10\x00\x0C\x00\xA3\x10\x00\x0D\x00\xA3\x10\x00\x0E\x00\xA3\x10\x00\x0F\x00\xA3\x10\x00\x10\x00\xA3\x10\x00\x11\x00\xA3\x10\x01\x13\x00\xA3\x10\x00\x17\x00\xA3\x10\x01\x19\x00\xA3\x10\x00\x20\x00\xA3\x10\x00\x21\x00\xA3\x10\x01\x29\x00\xA3\x10\x00\x2C\x00\xA3\x10\x00\x2E\x00\xA3\x10\x00\x2F\x00\xA3\x10\x00\x30\x00\xA3\x10\x01\x31\x00\xA3\x10\x00\x32\x00\xA3\x10\x01\x33\x00\xA3\x10\x00\x34\x00\xA3\x10\x01\x35\x00\xA3\x10\x00\x47\x00\xA3\x10\x01\x58\x00\xA3\x10\x00\x59\x00\xA3\x10\x00\x5A\x00\xA3\x10\x00\x5B\x00\xA3\x10\x00\x5C\x00\xA3\x10\x00\x5D\x00\xA3\x10\x00\x5E\x00\xA3\x10\x00\x02\x00\xC6\x10\x00\x01\x00\xC7\x10\x00\x02\x00\xC7\x10\x00\x09\x00\xF6\x10\x00\x14\x00\xF6\x10\x01\x35\x00\xF6\x10\x01\x36\x00\xF6\x10\x01\x37\x00\xF6\x10\x01\x38\x00\xF6\x10\x01\x3A\x00\xF6\x10\x01\x3B\x00\xF6\x10\x01\x3C\x00\xF6\x10\x01\x3D\x00\xF6\x10\x01\x3E\x00\xF6\x10\x01\x3F\x00\xF6\x10\x01\x40\x00\xF6\x10\x01\x41\x00\xF6\x10\x01\x44\x00\xF6\x10\x01\x46\x00\xF6\x10\x01\x47\x00\xF6\x10\x01\x48\x00\xF6\x10\x01\x49\x00\xF6\x10\x01\x4A\x00\xF6\x10\x01' \
	-A '\xb5\x62\x06\x8A\x44\x01\x01\x01\xC0\x00\x4B\x00\xF6\x10\x01\x4C\x00\xF6\x10\x01\x50\x00\xF6\x10\x01\x51\x00\xF6\x10\x01\x52\x00\xF6\x10\x01\x5A\x00\xF6\x10\x01\x11\x00\x01\x20\x00\x21\x00\x01\x20\x00\x31\x00\x01\x20\x00\x41\x00\x01\x20\x00\x51\x00\x01\x20\x00\x61\x00\x01\x20\x00\x71\x00\x01\x20\x00\x81\x00\x01\x20\x00\x91\x00\x01\x20\x00\xA1\x00\x01\x20\x00\xB1\x00\x01\x20\x00\xC1\x00\x01\x20\x00\xD1\x00\x01\x20\x00\xE1\x00\x01\x20\x00\x01\x00\x03\x20\x00\x02\x00\x03\x20\x00\x06\x00\x03\x20\x00\x07\x00\x03\x20\x00\x08\x00\x03\x20\x00\x0C\x00\x03\x20\x00\x0D\x00\x03\x20\x00\x0E\x00\x03\x20\x00\x14\x00\x03\x20\x00\x0C\x00\x05\x20\x01\x23\x00\x05\x20\x00\x30\x00\x05\x20\x01\x35\x00\x05\x20\x01\x01\x00\x0B\x20\x03\x02\x00\x0B\x20\x0A\x03\x00\x0B\x20\x28\x04\x00\x0B\x20\x05\x11\x00\x11\x20\x03\x1A\x00\x11\x20\x12\x1C\x00\x11\x20\x00\x20\x00\x11\x20\x64\x21\x00\x11\x20\x02\x22\x00\x11\x20\x00\x23\x00\x11\x20\x00\x24\x00\x11\x20\x01\x42\x00\x11\x20\x02\x43\x00\x11\x20\x03\x44\x00\x11\x20\x01\x45\x00\x11\x20\x01\x47\x00\x11\x20\x00\x51\x00\x11\x20\x00\xA1\x00\x11\x20\x01\xA2\x00\x11\x20\x20\xA3\x00\x11\x20\x09\xA4\x00\x11\x20\x0A\xAA\x00\x11\x20\x00\xAB\x00\x11\x20\x00\xC4\x00\x11\x20\x3C\x03\x00\x21\x20\x01\x38\x00\x25\x20\x00\x05\x00\x34\x20\x0A\x07\x00\x34\x20\x37\x21\x00\x34\x20\x00\x22\x00\x34\x20\x02' \
	-A '\xb5\x62\x06\x8A\x44\x01\x01\x01\x00\x01\x01\x00\x51\x20\x84\x09\x00\x51\x20\x01\x02\x00\x52\x20\x01\x03\x00\x52\x20\x00\x04\x00\x52\x20\x00\x08\x00\x52\x20\x00\x09\x00\x52\x20\x01\x01\x00\x64\x20\x32\x08\x00\x64\x20\x00\x09\x00\x64\x20\x00\x06\x00\x91\x20\x00\x07\x00\x91\x20\x00\x0A\x00\x91\x20\x00\x10\x00\x91\x20\x00\x11\x00\x91\x20\x00\x14\x00\x91\x20\x00\x15\x00\x91\x20\x00\x16\x00\x91\x20\x00\x19\x00\x91\x20\x00\x1A\x00\x91\x20\x00\x1B\x00\x91\x20\x00\x1E\x00\x91\x20\x00\x24\x00\x91\x20\x00\x25\x00\x91\x20\x00\x28\x00\x91\x20\x00\x29\x00\x91\x20\x00\x2A\x00\x91\x20\x00\x2D\x00\x91\x20\x00\x38\x00\x91\x20\x00\x39\x00\x91\x20\x00\x3C\x00\x91\x20\x00\x3D\x00\x91\x20\x00\x3E\x00\x91\x20\x00\x41\x00\x91\x20\x00\x42\x00\x91\x20\x00\x43\x00\x91\x20\x00\x46\x00\x91\x20\x00\x47\x00\x91\x20\x00\x48\x00\x91\x20\x00\x4B\x00\x91\x20\x00\x4C\x00\x91\x20\x00\x4D\x00\x91\x20\x00\x50\x00\x91\x20\x00\x51\x00\x91\x20\x00\x52\x00\x91\x20\x00\x55\x00\x91\x20\x00\x56\x00\x91\x20\x00\x57\x00\x91\x20\x00\x5A\x00\x91\x20\x00\x5B\x00\x91\x20\x00\x5C\x00\x91\x20\x00\x5F\x00\x91\x20\x00\x60\x00\x91\x20\x00\x61\x00\x91\x20\x00\x64\x00\x91\x20\x00\x65\x00\x91\x20\x00\x66\x00\x91\x20\x00\x69\x00\x91\x20\x00\x6A\x00\x91\x20\x00\x6B\x00\x91\x20\x00\x6E\x00\x91\x20\x00\x83\x00\x91\x20\x00\x84\x00\x91\x20\x00\x87\x00\x91\x20\x00' \
	-A '\xb5\x62\x06\x8A\x44\x01\x01\x01\x40\x01\x92\x00\x91\x20\x00\x93\x00\x91\x20\x00\x96\x00\x91\x20\x00\x97\x00\x91\x20\x00\x98\x00\x91\x20\x00\x9B\x00\x91\x20\x00\xA6\x00\x91\x20\x00\xA7\x00\x91\x20\x00\xAA\x00\x91\x20\x00\xAB\x00\x91\x20\x01\xAC\x00\x91\x20\x01\xAF\x00\x91\x20\x01\xB0\x00\x91\x20\x01\xB1\x00\x91\x20\x01\xB4\x00\x91\x20\x01\xB5\x00\x91\x20\x00\xB6\x00\x91\x20\x00\xB9\x00\x91\x20\x00\xBA\x00\x91\x20\x01\xBB\x00\x91\x20\x01\xBE\x00\x91\x20\x01\xBF\x00\x91\x20\x01\xC0\x00\x91\x20\x01\xC3\x00\x91\x20\x01\xC4\x00\x91\x20\x01\xC5\x00\x91\x20\x01\xC8\x00\x91\x20\x01\xC9\x00\x91\x20\x01\xCA\x00\x91\x20\x01\xCD\x00\x91\x20\x01\xCE\x00\x91\x20\x00\xCF\x00\x91\x20\x00\xD2\x00\x91\x20\x00\xD3\x00\x91\x20\x00\xD4\x00\x91\x20\x00\xD7\x00\x91\x20\x00\xD8\x00\x91\x20\x01\xD9\x00\x91\x20\x01\xDC\x00\x91\x20\x01\xDD\x00\x91\x20\x00\xDE\x00\x91\x20\x00\xE1\x00\x91\x20\x00\xEC\x00\x91\x20\x00\xED\x00\x91\x20\x00\xF0\x00\x91\x20\x00\xF1\x00\x91\x20\x00\xF2\x00\x91\x20\x00\xF5\x00\x91\x20\x00\xF6\x00\x91\x20\x00\xF7\x00\x91\x20\x00\xFA\x00\x91\x20\x00\x19\x01\x91\x20\x00\x1A\x01\x91\x20\x00\x1D\x01\x91\x20\x00\x1E\x01\x91\x20\x00\x1F\x01\x91\x20\x00\x22\x01\x91\x20\x00\x2D\x01\x91\x20\x00\x2E\x01\x91\x20\x00\x31\x01\x91\x20\x00\x37\x01\x91\x20\x00\x38\x01\x91\x20\x00\x3B\x01\x91\x20\x00\x55\x01\x91\x20\x00' \
	-A '\xb5\x62\x06\x8A\x44\x01\x01\x01\x80\x01\x56\x01\x91\x20\x00\x59\x01\x91\x20\x00\x5F\x01\x91\x20\x00\x60\x01\x91\x20\x00\x63\x01\x91\x20\x00\x78\x01\x91\x20\x00\x79\x01\x91\x20\x00\x7C\x01\x91\x20\x00\x7D\x01\x91\x20\x00\x7E\x01\x91\x20\x00\x81\x01\x91\x20\x00\x82\x01\x91\x20\x00\x83\x01\x91\x20\x00\x86\x01\x91\x20\x00\x87\x01\x91\x20\x00\x88\x01\x91\x20\x00\x8B\x01\x91\x20\x00\x8C\x01\x91\x20\x00\x8D\x01\x91\x20\x00\x90\x01\x91\x20\x00\x91\x01\x91\x20\x00\x92\x01\x91\x20\x00\x95\x01\x91\x20\x00\x96\x01\x91\x20\x00\x97\x01\x91\x20\x00\x9A\x01\x91\x20\x00\x9B\x01\x91\x20\x00\x9C\x01\x91\x20\x00\x9F\x01\x91\x20\x00\xA0\x01\x91\x20\x00\xA1\x01\x91\x20\x00\xA4\x01\x91\x20\x00\xA5\x01\x91\x20\x00\xA6\x01\x91\x20\x00\xA9\x01\x91\x20\x00\xAA\x01\x91\x20\x00\xAB\x01\x91\x20\x00\xAE\x01\x91\x20\x00\xAF\x01\x91\x20\x00\xB0\x01\x91\x20\x00\xB3\x01\x91\x20\x00\xB4\x01\x91\x20\x00\xB5\x01\x91\x20\x00\xB8\x01\x91\x20\x00\xB9\x01\x91\x20\x00\xBA\x01\x91\x20\x00\xBD\x01\x91\x20\x00\xC8\x01\x91\x20\x00\xC9\x01\x91\x20\x00\xCC\x01\x91\x20\x00\xCD\x01\x91\x20\x00\xCE\x01\x91\x20\x00\xD1\x01\x91\x20\x00\xD2\x01\x91\x20\x00\xD3\x01\x91\x20\x00\xD6\x01\x91\x20\x00\xDC\x01\x91\x20\x00\xDD\x01\x91\x20\x00\xE0\x01\x91\x20\x00\xE1\x01\x91\x20\x00\xE2\x01\x91\x20\x00\xE5\x01\x91\x20\x00\xE6\x01\x91\x20\x00\xE7\x01\x91\x20\x00' \
	-A '\xb5\x62\x06\x8A\x44\x01\x01\x01\xC0\x01\xEA\x01\x91\x20\x00\xF5\x01\x91\x20\x00\xF6\x01\x91\x20\x00\xF9\x01\x91\x20\x00\xFF\x01\x91\x20\x00\x00\x02\x91\x20\x00\x03\x02\x91\x20\x00\x04\x02\x91\x20\x00\x05\x02\x91\x20\x00\x08\x02\x91\x20\x00\x09\x02\x91\x20\x00\x0A\x02\x91\x20\x00\x0D\x02\x91\x20\x00\x0E\x02\x91\x20\x00\x0F\x02\x91\x20\x00\x12\x02\x91\x20\x00\x13\x02\x91\x20\x00\x14\x02\x91\x20\x00\x17\x02\x91\x20\x00\x18\x02\x91\x20\x00\x19\x02\x91\x20\x00\x1C\x02\x91\x20\x00\x2C\x02\x91\x20\x00\x2D\x02\x91\x20\x00\x30\x02\x91\x20\x00\x31\x02\x91\x20\x00\x32\x02\x91\x20\x00\x35\x02\x91\x20\x00\x36\x02\x91\x20\x00\x37\x02\x91\x20\x00\x3A\x02\x91\x20\x00\x3B\x02\x91\x20\x00\x3C\x02\x91\x20\x00\x3F\x02\x91\x20\x00\x40\x02\x91\x20\x00\x41\x02\x91\x20\x00\x44\x02\x91\x20\x00\x4A\x02\x91\x20\x00\x4B\x02\x91\x20\x00\x4E\x02\x91\x20\x00\x54\x02\x91\x20\x00\x55\x02\x91\x20\x00\x58\x02\x91\x20\x00\x5E\x02\x91\x20\x00\x5F\x02\x91\x20\x00\x62\x02\x91\x20\x00\x90\x02\x91\x20\x00\x91\x02\x91\x20\x00\x94\x02\x91\x20\x00\xA4\x02\x91\x20\x00\xA5\x02\x91\x20\x00\xA8\x02\x91\x20\x00\x2C\x03\x91\x20\x00\x2D\x03\x91\x20\x00\x30\x03\x91\x20\x00\x45\x03\x91\x20\x00\x46\x03\x91\x20\x00\x49\x03\x91\x20\x00\x4A\x03\x91\x20\x00\x4B\x03\x91\x20\x00\x4E\x03\x91\x20\x00\x4F\x03\x91\x20\x00\x50\x03\x91\x20\x00\x53\x03\x91\x20\x00' \
	-A '\xb5\x62\x06\x8A\x44\x01\x01\x01\x00\x02\x54\x03\x91\x20\x00\x55\x03\x91\x20\x00\x58\x03\x91\x20\x00\x59\x03\x91\x20\x00\x5A\x03\x91\x20\x00\x5D\x03\x91\x20\x00\x7C\x03\x91\x20\x00\x7D\x03\x91\x20\x00\x80\x03\x91\x20\x00\x86\x03\x91\x20\x00\x87\x03\x91\x20\x00\x8A\x03\x91\x20\x00\x8B\x03\x91\x20\x00\x8C\x03\x91\x20\x00\x8F\x03\x91\x20\x00\x00\x04\x91\x20\x00\x01\x04\x91\x20\x00\x04\x04\x91\x20\x00\x1A\x04\x91\x20\x00\x1B\x04\x91\x20\x00\x1E\x04\x91\x20\x00\x30\x04\x91\x20\x00\x31\x04\x91\x20\x00\x34\x04\x91\x20\x00\x35\x04\x91\x20\x00\x36\x04\x91\x20\x00\x39\x04\x91\x20\x00\x40\x04\x91\x20\x00\x41\x04\x91\x20\x00\x44\x04\x91\x20\x00\x50\x04\x91\x20\x00\x51\x04\x91\x20\x00\x54\x04\x91\x20\x00\x55\x04\x91\x20\x00\x56\x04\x91\x20\x00\x59\x04\x91\x20\x00\x65\x04\x91\x20\x00\x66\x04\x91\x20\x00\x69\x04\x91\x20\x00\x80\x04\x91\x20\x00\x81\x04\x91\x20\x00\x84\x04\x91\x20\x00\x85\x04\x91\x20\x00\x86\x04\x91\x20\x00\x89\x04\x91\x20\x00\x90\x04\x91\x20\x00\x91\x04\x91\x20\x00\x94\x04\x91\x20\x00\x95\x04\x91\x20\x00\x96\x04\x91\x20\x00\x99\x04\x91\x20\x00\x00\x05\x91\x20\x00\x01\x05\x91\x20\x00\x04\x05\x91\x20\x00\x05\x05\x91\x20\x00\x06\x05\x91\x20\x00\x09\x05\x91\x20\x00\x15\x05\x91\x20\x00\x16\x05\x91\x20\x00\x19\x05\x91\x20\x00\x25\x05\x91\x20\x00\x26\x05\x91\x20\x00\x29\x05\x91\x20\x00\x30\x05\x91\x20\x00' \
	-A '\xb5\x62\x06\x8A\x44\x01\x01\x01\x40\x02\x31\x05\x91\x20\x00\x34\x05\x91\x20\x00\x35\x05\x91\x20\x00\x36\x05\x91\x20\x00\x39\x05\x91\x20\x00\x40\x05\x91\x20\x00\x41\x05\x91\x20\x00\x44\x05\x91\x20\x00\x45\x05\x91\x20\x00\x46\x05\x91\x20\x00\x49\x05\x91\x20\x00\x50\x05\x91\x20\x00\x51\x05\x91\x20\x00\x54\x05\x91\x20\x00\x55\x05\x91\x20\x00\x56\x05\x91\x20\x00\x59\x05\x91\x20\x00\x60\x05\x91\x20\x00\x61\x05\x91\x20\x00\x64\x05\x91\x20\x00\x65\x05\x91\x20\x00\x66\x05\x91\x20\x00\x69\x05\x91\x20\x00\x90\x05\x91\x20\x00\x91\x05\x91\x20\x00\x94\x05\x91\x20\x00\x00\x06\x91\x20\x00\x01\x06\x91\x20\x00\x04\x06\x91\x20\x00\x34\x06\x91\x20\x00\x35\x06\x91\x20\x00\x38\x06\x91\x20\x00\x52\x06\x91\x20\x00\x53\x06\x91\x20\x00\x56\x06\x91\x20\x00\x57\x06\x91\x20\x00\x58\x06\x91\x20\x00\x5B\x06\x91\x20\x00\x5C\x06\x91\x20\x00\x5D\x06\x91\x20\x00\x60\x06\x91\x20\x00\x61\x06\x91\x20\x00\x62\x06\x91\x20\x00\x65\x06\x91\x20\x00\x66\x06\x91\x20\x00\x67\x06\x91\x20\x00\x6A\x06\x91\x20\x00\x70\x06\x91\x20\x00\x71\x06\x91\x20\x00\x74\x06\x91\x20\x00\x7F\x06\x91\x20\x00\x80\x06\x91\x20\x00\x83\x06\x91\x20\x00\x84\x06\x91\x20\x00\x85\x06\x91\x20\x00\x88\x06\x91\x20\x00\x89\x06\x91\x20\x00\x8A\x06\x91\x20\x00\x8D\x06\x91\x20\x00\x9D\x06\x91\x20\x00\x9E\x06\x91\x20\x00\xA1\x06\x91\x20\x00\xA2\x06\x91\x20\x00\xA3\x06\x91\x20\x00' \
	-A '\xb5\x62\x06\x8A\x47\x01\x01\x01\x80\x02\xA6\x06\x91\x20\x00\xA7\x06\x91\x20\x00\xA8\x06\x91\x20\x00\xAB\x06\x91\x20\x00\xC0\x06\x91\x20\x01\xC1\x06\x91\x20\x01\xC4\x06\x91\x20\x01\x01\x00\x92\x20\x00\x02\x00\x92\x20\x00\x05\x00\x92\x20\x00\x06\x00\x92\x20\x07\x07\x00\x92\x20\x07\x0A\x00\x92\x20\x07\x01\x00\x93\x20\x2A\x02\x00\x93\x20\x00\x07\x00\x93\x20\x00\x31\x00\x93\x20\x00\x32\x00\x93\x20\x00\x03\x00\xA2\x20\x00\x05\x00\xA2\x20\x00\x36\x00\xA3\x20\x07\x37\x00\xA3\x20\x06\x38\x00\xA3\x20\x05\x51\x00\xA3\x20\x00\x54\x00\xA3\x20\x00\x55\x00\xA3\x20\x00\x56\x00\xA3\x20\x00\x57\x00\xA3\x20\x00\x01\x00\xC5\x20\x14\x02\x00\xC5\x20\x8C\x01\x00\xC6\x20\x08\x04\x00\xC6\x20\x00\x06\x00\xC6\x20\x01\x08\x00\xC6\x20\x00\x0A\x00\xC6\x20\x01\x0C\x00\xC6\x20\x00\x0E\x00\xC6\x20\x01\x10\x00\xC6\x20\x00\x12\x00\xC6\x20\x01\x14\x00\xC6\x20\x00\x16\x00\xC6\x20\x01\x18\x00\xC6\x20\x00\x1A\x00\xC6\x20\x01\x1C\x00\xC6\x20\x00\x1E\x00\xC6\x20\x01\x20\x00\xC6\x20\x00\x22\x00\xC6\x20\x01\x24\x00\xC6\x20\x00\x26\x00\xC6\x20\x01\x28\x00\xC6\x20\x00\x2A\x00\xC6\x20\x01\x2C\x00\xC6\x20\x00\x2E\x00\xC6\x20\x01\x30\x00\xC6\x20\x00\x32\x00\xC6\x20\x01\x03\x00\xC7\x20\x16\x01\x00\xF6\x20\x00\x39\x00\xF6\x20\x03\x45\x00\xF6\x20\x09\x53\x00\xF6\x20\x04\x54\x00\xF6\x20\x08\x10\x00\x01\x30\x00\x00\x20\x00\x01\x30\x00\x00\x30\x00\x01\x30\x00\x00' \
	-A '\xb5\x62\x06\x8A\xAA\x01\x01\x01\xC0\x02\x40\x00\x01\x30\x00\x00\x50\x00\x01\x30\x00\x00\x60\x00\x01\x30\x00\x00\x70\x00\x01\x30\x00\x00\x80\x00\x01\x30\x00\x00\x90\x00\x01\x30\x00\x00\xA0\x00\x01\x30\x00\x00\xB0\x00\x01\x30\x00\x00\xC0\x00\x01\x30\x00\x00\xD0\x00\x01\x30\x00\x00\xE0\x00\x01\x30\x00\x00\x01\x00\x02\x30\x64\x00\x01\x00\x05\x30\x32\x00\x17\x00\x11\x30\xC9\x08\xB1\x00\x11\x30\xFA\x00\xB2\x00\x11\x30\xFA\x00\xB3\x00\x11\x30\x64\x00\xB4\x00\x11\x30\x5E\x01\xB5\x00\x11\x30\x96\x00\x01\x00\x21\x30\xE8\x03\x02\x00\x21\x30\x01\x00\x3B\x00\x25\x30\x00\x00\x06\x00\x34\x30\x46\x00\x08\x00\x34\x30\x91\x00\x08\x00\x36\x30\x00\x00\x33\x00\x93\x30\x00\x00\x04\x00\xA2\x30\x00\x00\x3C\x00\xA3\x30\xF4\x01\x45\x00\xA3\x30\xB0\x04\x46\x00\xA3\x30\xE8\x03\x48\x00\xA3\x30\x00\x00\x05\x00\xC6\x30\x00\x00\x09\x00\xC6\x30\x00\x00\x0D\x00\xC6\x30\x00\x00\x11\x00\xC6\x30\x00\x00\x15\x00\xC6\x30\x00\x00\x19\x00\xC6\x30\x00\x00\x1D\x00\xC6\x30\x00\x00\x21\x00\xC6\x30\x00\x00\x25\x00\xC6\x30\x00\x00\x29\x00\xC6\x30\x00\x00\x2D\x00\xC6\x30\x00\x00\x31\x00\xC6\x30\x00\x00\x0A\x00\xF6\x30\x00\x00\x0B\x00\xF6\x30\x00\x00\x03\x00\x03\x40\x00\x00\x00\x00\x04\x00\x03\x40\x00\x00\x00\x00\x05\x00\x03\x40\x00\x00\x00\x00\x09\x00\x03\x40\x00\x00\x00\x00\x0A\x00\x03\x40\x00\x00\x00\x00\x0B\x00\x03\x40\x00\x00\x00\x00\x0F\x00\x03\x40\x00\x00\x00\x00\x10\x00\x03\x40\x00\x00\x00\x00\x11\x00\x03\x40\x00\x00\x00\x00\x02\x00\x05\x40\x40\x42\x0F\x00\x03\x00\x05\x40\x40\x42\x0F\x00\x04\x00\x05\x40\x00\x00\x00\x00\x05\x00\x05\x40\xA0\x86\x01\x00\x06\x00\x05\x40\x00\x00\x00\x00\x24\x00\x05\x40\x01\x00\x00\x00\x25\x00\x05\x40\x01\x00\x00\x00\x64\x00\x11\x40\x00\x00\x00\x00\x65\x00\x11\x40\x00\x00\x00\x00\x66\x00\x11\x40\x00\x00\x00\x00' \
	-A '\xb5\x62\x06\x8A\x64\x02\x01\x01\x00\x03\x67\x00\x11\x40\x00\x00\x00\x00\x68\x00\x11\x40\x00\x00\x00\x00\x69\x00\x11\x40\x00\x00\x00\x00\x6A\x00\x11\x40\x00\x00\x00\x00\xC1\x00\x11\x40\x00\x00\x00\x00\xC2\x00\x11\x40\x10\x27\x00\x00\xD1\x00\x11\x40\x00\x00\x00\x00\xD2\x00\x11\x40\x00\x00\x00\x00\xD3\x00\x11\x40\x00\x00\x00\x00\xD8\x00\x11\x40\x00\x75\x12\x00\xD9\x00\x11\x40\x00\x75\x12\x00\xDA\x00\x11\x40\x80\x3A\x09\x00\xDB\x00\x11\x40\x80\x3A\x09\x00\xDC\x00\x11\x40\x80\x3A\x09\x00\x12\x00\x34\x40\xF0\xF1\xFF\xFF\x13\x00\x34\x40\x30\x2A\x00\x00\x15\x00\x34\x40\xFF\xFF\xFF\xFF\x01\x00\x52\x40\x00\x96\x00\x00\x28\x00\xA3\x40\x00\x00\x00\x00\x2A\x00\xA3\x40\x00\x00\x00\x00\x2B\x00\xA3\x40\x00\x00\x00\x00\x41\x00\xA3\x40\x00\x00\x00\x00\x42\x00\xA3\x40\xD0\x07\x00\x00\x43\x00\xA3\x40\xE8\x03\x00\x00\x44\x00\xA3\x40\xF4\x01\x00\x00\x52\x00\xA3\x40\x08\x07\x00\x00\x53\x00\xA3\x40\x00\x00\x00\x00\x01\x00\xA4\x40\x00\xB0\x71\x0B\x03\x00\xA4\x40\x00\xB0\x71\x0B\x04\x00\xA4\x40\x00\xB0\x71\x0B\x05\x00\xA4\x40\x00\xB0\x71\x0B\x07\x00\xA4\x40\x00\x90\xD0\x03\x08\x00\xA4\x40\x00\x90\xD0\x03\x0A\x00\xA4\x40\x00\xD8\xB8\x05\x0C\x00\xA4\x40\x00\x24\xF4\x00\x0D\x00\xA4\x40\x80\xBA\x8C\x01\x10\x00\xA4\x40\x00\xB0\x71\x0B\x11\x00\xA4\x40\x00\x12\x7A\x00\x01\x00\xA6\x40\x00\x00\x00\x00\x14\x00\xD0\x40\x31\x00\x00\x00\x2A\x00\x05\x50\x00\x00\x00\x00\x00\x00\x00\x00\x2B\x00\x05\x50\x00\x00\x00\x00\x00\x00\x24\x40\x62\x00\x11\x50\x00\x00\x00\x40\xA6\x54\x58\x41\x63\x00\x11\x50\x88\x6D\x74\x96\x1D\xA4\x72\x40\x01\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x02\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x03\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x04\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x05\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x06\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x07\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x08\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x09\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x0A\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x0B\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x0C\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x0D\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x0E\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x0F\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x10\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x11\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x12\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x13\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x14\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF' \
	-A '\xb5\x62\x06\x8A\x60\x01\x01\x01\x40\x03\x15\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x17\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x18\x00\x18\x50\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x06\x00\x36\x50\x88\xAB\x03\x00\x00\x00\x00\x00\x49\x00\xA3\x50\x4E\x45\x4F\x2D\x46\x31\x30\x54\x07\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x0B\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x0F\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x13\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x17\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x1B\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x1F\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x23\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x27\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x2B\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x2F\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x33\x00\xC6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\xC7\x50\x4E\x6F\x74\x69\x63\x65\x3A\x20\x05\x00\xC7\x50\x6E\x6F\x20\x64\x61\x74\x61\x20\x06\x00\xC7\x50\x73\x61\x76\x65\x64\x21\x00\x00\x07\x00\xC7\x50\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xF6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\xF6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\xF6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x05\x00\xF6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x06\x00\xF6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x07\x00\xF6\x50\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\xF6\x50\x00\x00\x00\x00\x00\x00\x00\x00' \
	< /dev/null > /dev/null
