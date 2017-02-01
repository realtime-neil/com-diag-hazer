/* vi: set ts=4 expandtab shiftwidth=4: */
/**
 * @file
 *
 * Copyright 2017 Digital Aggregates Corporation, Colorado, USA<BR>
 * Licensed under the terms in README.h<BR>
 * Chip Overclock (coverclock@diag.com)<BR>
 * http://www.diag.com/navigation/downloads/Assay.html<BR>
 *
 * EXAMPLE
 *
 * serialtool -D /dev/ttyUSB0 -b 4800 -8 -1 -n -l | unittest-hazer
 */

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "com/diag/hazer/hazer.h"
#include "com/diag/hazer/hazer_nmea_gps.h"

void print(const hazer_position_t * pp)
{
    uint64_t nanoseconds = 0;
    int year = 0;
    int month = 0;
    int day = 0;
    int hour = 0;
    int minute = 0;
    int second = 0;
    int degrees = 0;
    int minutes = 0;
    int seconds = 0;
    int direction = 0;

    nanoseconds = pp->dmy_nanoseconds;
    if (nanoseconds == 0) { return; }
    nanoseconds += pp->utc_nanoseconds;
    hazer_format_nanoseconds2timestamp(nanoseconds, &year, &month, &day, &hour, &minute, &second, &nanoseconds);
    fprintf(stderr, "%04d-%02d-%02dT%02d:%02d:%02dZ", year, month, day, hour, minute, second);
    fputc(' ', stderr);

    hazer_format_degrees2position(pp->lat_degrees, &degrees, &minutes, &seconds, &direction);
    fprintf(stderr, "%u:%02u:%02u%c", degrees, minutes, seconds, direction < 0 ? 'S' : 'N');
    fputc(' ', stderr);

    hazer_format_degrees2position(pp->lon_degrees, &degrees, &minutes, &seconds, &direction);
    fprintf(stderr, "%u:%02u:%02u%c", degrees, minutes, seconds, direction < 0 ? 'W' : 'E');
    fputc(' ', stderr);

    fprintf(stderr, "%lf", pp->sog_knots);
    fputc(' ', stderr);

    fprintf(stderr, "%lf", pp->cog_degrees);
    fputc(' ', stderr);

    fputc('\n', stderr);
}

int main(int argc, char * argv[])
{
    const char * program = (const char *)0;
    hazer_state_t state = HAZER_STATE_EOF;
    hazer_buffer_t buffer = { 0 };
    hazer_vector_t vector = { 0 };
    hazer_position_t position = { 0 };
    int rc = 0;
    int ch = EOF;
    char * bb = (char *)0;
    ssize_t size = 0;
    ssize_t ss = 0;
    size_t current = 0;
    int end = 0;
    ssize_t check = 0;
    ssize_t count = 0;
    char ** vv = (char **)0;
    int tt = 0;
    uint8_t cs = 0;
    uint8_t ck = 0;
    char msn = '\0';
    char lsn = '\0';

    program = ((program = strrchr(argv[0], '/')) == (char *)0) ? argv[0] : program + 1;

    rc = hazer_initialize();
    assert(rc == 0);

    if (argc > 1) {
        hazer_debug(stderr);
    }

    while (!0) {

        state = HAZER_STATE_START;

        while (!0) {
            ch = fgetc(stdin);
            state = hazer_machine(state, ch, buffer, sizeof(buffer), &bb, &ss);
            if (state == HAZER_STATE_END) {
                break;
            } else if  (state == HAZER_STATE_EOF) {
                fprintf(stderr, "%s: EOF\n", program);
                break;
            } else {
                /* Do nothing. */
            }
        }

        size = ss;
        assert(size > 0);

        assert(buffer[0] == '$');
        assert(buffer[size - 1] == '\0');
        assert(buffer[size - 2] == '\n');
        assert(buffer[size - 3] == '\r');
        assert(buffer[size - 6] == '*');

        cs = hazer_checksum(buffer, size);

        rc = hazer_characters2checksum(buffer[size - 5], buffer[size - 4], &ck);
        assert(rc >= 0);
        assert(ck == cs);

        rc = hazer_checksum2characters(ck, &msn, &lsn);
        assert(rc >= 0);
        assert(msn == buffer[size - 5]);
        assert(lsn == buffer[size - 4]);

        rc = hazer_characters2checksum(msn, lsn, &ck);
        assert(rc >= 0);
        assert(ck == cs);

        count = hazer_tokenize(vector, sizeof(vector) / sizeof(vector[0]),  buffer, size);
        assert(count >= 0);
        assert(vector[count] == (char *)0);
        assert(count < (sizeof(vector) / sizeof(vector[0])));

        for (vv = vector, tt = 1; *vv != (char *)0; ++vv, ++tt) {
            fputs(*vv, stdout);
            fputc((tt == count) ? '\n' : ',', stdout);
        }
        fflush(stdout);

        if (hazer_parse_gga(&position, vector, count)) {
            print(&position);
        } else if (hazer_parse_rmc(&position, vector, count)) {
            print(&position);
        } else {
            /* Do nothing. */
        }
    }

    return 0;
}
