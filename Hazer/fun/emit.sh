#!/bin/bash
# Copyright 2021 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer

PROGRAM=$(basename ${0})

. $(readlink -e $(dirname ${0})/../bin)/setup

eval coreable gpstool \
	-D /dev/tty -b 38400 -8 -n -n \
	-W '$PUBX,00' \
	-U '\xb5\x62\x06\x01\x03\x00\x01\x14\x01' \
	-Z 'LYNQ012ARHM' \
	-Z 'LYNQ012ARHM' \
	-u -v
