#!/bin/bash
# Copyright 2019 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# 
# ABSTRACT
#
# Helper script used to follow the log or the screens from the Tumbleweed
# scripts.
#
# USAGE
#
#    peruse TASK FILE
#
# EXAMPLES
#
#    peruse base out
#    peruse base err
#    peruse rover out
#    peruse rover err
#    peruse router err

PROGRAM=$(basename ${0})
TASK=${1}
FILE=${2}

. $(readlink -e $(dirname ${0})/../bin)/setup

LOG=$(readlink -e $(dirname ${0})/../log)

if [[ "${FILE}" == "err" ]]; then
    CMD="tail -f"
elif [[ "${FILE}" == "out" ]]; then
    CMD="headless"
else
    CMD="cat"
fi

exec ${CMD} ${LOG}/${TASK}.${FILE}