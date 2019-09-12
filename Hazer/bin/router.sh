#!/bin/bash
# Copyright 2019 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer

PROGRAM=$(basename ${0})
ROUTER=${1:-":tumbleweed"}

. $(readlink -e $(dirname ${0})/../bin)/setup

LOGDIR=${TMPDIR:="/tmp"}/hazer/log
mkdir -p ${LOGDIR}

export COM_DIAG_DIMINUTO_LOG_MASK=0xfe

exec coreable rtktool \
    -p ${ROUTER} -t 30 \
    < /dev/null 1> /dev/null 2> ${LOGDIR}/${PROGRAM}.err
