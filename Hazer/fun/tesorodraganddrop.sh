#!/bin/bash
# Copyright 2021 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer

PROGRAM=$(basename ${0})
OUTPUT=${1:-${TMPDIR:="/tmp"}/${PROGRAM}/observation.json}
INPUT=${2:-$(readlink -e $(dirname ${0})/../../../dat/yodel)/20200917/vehicle.csv}

. $(readlink -e $(dirname ${0})/../bin)/setup

mkdir -p $(dirname ${OUTPUT})

rm -f ${OUTPUT}

csvmeter < ${INPUT} | csv2dgm -v -F ${OUTPUT} -M 0644 -j
