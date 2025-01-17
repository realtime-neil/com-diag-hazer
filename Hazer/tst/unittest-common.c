/* vi: set ts=4 expandtab shiftwidth=4: */
/**
 * @file
 * @copyright Copyright 2021 Digital Aggregates Corporation, Colorado, USA.
 * @note Licensed under the terms in LICENSE.txt.
 * @brief This is the NMEA unit test.
 * @author Chip Overclock <mailto:coverclock@diag.com>
 * @see Hazer <https://github.com/coverclock/com-diag-hazer>
 * @details
 */

#include "com/diag/diminuto/diminuto_countof.h"
#include "com/diag/diminuto/diminuto_minmaxof.h"
#include <locale.h>
#include <stdio.h>
#include <string.h>
#include "com/diag/hazer/common.h"
#include "com/diag/hazer/machine.h"
#include "com/diag/hazer/hazer.h"
#include "com/diag/hazer/yodel.h"
#include "com/diag/hazer/tumbleweed.h"
#include "com/diag/hazer/calico.h"
#include "./unittest.h"

int main(void)
{
    {
        int rc;
        char * env;
        char * locale;
        static const char * ENV = "LANG";
        static const char * LOCALE = "en_US.UTF-8";

        fprintf(stderr, "sizeof(wint_t)=%zu\n", sizeof(wint_t));
        assert(ENV != (const char *)0);
        rc = setenv(ENV, LOCALE, 0);
        assert(rc == 0);
        env = getenv(ENV);
        assert(env != (char *)0);
        fprintf(stderr, "%s=\"%s\"\n", ENV, env);
        fprintf(stderr, "LC_ALL=%d\n", LC_ALL);
        locale = setlocale(LC_ALL, "");
        assert(locale != (char *)0);
        fprintf(stderr, "locale=\"%s\"\n", locale);
        assert(strcmp(locale, LOCALE) == 0);
        fprintf(stderr, "COMMON_DEGREE_VALUE=0x%x=\'%lc\'\n", COMMON_DEGREE_VALUE, COMMON_DEGREE_VALUE);
        fprintf(stderr, "COMMON_DEGREE=0x%x=\'%lc\'\n", COMMON_DEGREE, COMMON_DEGREE);
        fprintf(stderr, "COMMON_PLUSMINUS_VALUE=0x%x=\'%lc\'\n", COMMON_PLUSMINUS_VALUE, COMMON_PLUSMINUS_VALUE);
        fprintf(stderr, "COMMON_PLUSMINUS=0x%x=\'%lc\'\n", COMMON_PLUSMINUS, COMMON_PLUSMINUS);
    }

    {
        assert(common_abs64((int64_t)0) == (int64_t)0);
        assert(common_abs64((int64_t)1) == (int64_t)1);
        assert(common_abs64((int64_t)-1) == (int64_t)1);
        assert(common_abs64(diminuto_maximumof(int64_t)) == diminuto_maximumof(int64_t));
        /*
         * In two's complement encoding, the dynamic range of the 
         * positive integers is one greater than that of the negative
         * integers because zero is considered positive. Consider that
         * taking the two's complement of the largest (numerically smallest)
         * negative number yields the same negative number.
         */
        assert(common_abs64(diminuto_minimumof(int64_t) + 1) == (diminuto_maximumof(int64_t)));
    }

    {
        int ch;
        int ii;

        /*
         * These functions used to be part of common.
         * We make ch an int because that's what fgetc() returns.
         * We cast to uint8_t because sometimes the sign difference
         * causes a warning. (Note that on some architectures, char
         * is signed by default, and on others unsigned by default.
         * uint8_t however is obviously always unsigned.)
         */

        ii = 0;
        for (ch = 0x00; ch <= 0xff; ++ch) {
            if (ch == '$') {
                assert(hazer_is_nmea((uint8_t)ch));
            } else {
                assert(!hazer_is_nmea((uint8_t)ch));
            }
            if (ch == 0xb5) {
                assert(yodel_is_ubx((uint8_t)ch));
            } else {
                assert(!yodel_is_ubx((uint8_t)ch));
            }
            if (ch == 0xd3) {
                assert(tumbleweed_is_rtcm((uint8_t)ch));
            } else {
                assert(!tumbleweed_is_rtcm((uint8_t)ch));
            }
            if (ch == 0x10) {
                assert(calico_is_cpo((uint8_t)ch));
            } else {
                assert(!calico_is_cpo((uint8_t)ch));
            }
            ++ii;
        }

        assert(ii == 256);
    }

    {
        static const hazer_state_t nmea[] = {
            HAZER_STATE_STOP,
            HAZER_STATE_START,
            HAZER_STATE_PAYLOAD,
            HAZER_STATE_MSN,
            HAZER_STATE_LSN,
            HAZER_STATE_CR,
            HAZER_STATE_LF,
            HAZER_STATE_END,
        };
        static const yodel_state_t ubx[] = {
            YODEL_STATE_STOP,
            YODEL_STATE_START,
            YODEL_STATE_SYNC_2,
            YODEL_STATE_CLASS,
            YODEL_STATE_ID,
            YODEL_STATE_LENGTH_1,
            YODEL_STATE_LENGTH_2,
            YODEL_STATE_PAYLOAD,
            YODEL_STATE_CK_A,
            YODEL_STATE_CK_B,
            YODEL_STATE_END,
        };
        static const tumbleweed_state_t rtcm[] = {
            TUMBLEWEED_STATE_STOP,
            TUMBLEWEED_STATE_START,
            TUMBLEWEED_STATE_LENGTH_1,
            TUMBLEWEED_STATE_LENGTH_2,
            TUMBLEWEED_STATE_PAYLOAD,
            TUMBLEWEED_STATE_CRC_1,
            TUMBLEWEED_STATE_CRC_2,
            TUMBLEWEED_STATE_CRC_3,
            TUMBLEWEED_STATE_END,
        };
        static const calico_state_t cpo[] = {
            CALICO_STATE_STOP,
            CALICO_STATE_START,
            CALICO_STATE_ID,
            CALICO_STATE_SIZE,
            CALICO_STATE_SIZE_DLE,
            CALICO_STATE_PAYLOAD,
            CALICO_STATE_PAYLOAD_DLE,
            CALICO_STATE_CS,
            CALICO_STATE_CS_DLE,
            CALICO_STATE_DLE,
            CALICO_STATE_ETX,
            CALICO_STATE_END,
        };
        int nn;
        int uu;
        int rr;
        int cc;
        int ii;

        ii = 0;
        for (nn = 0; nn < countof(nmea); ++nn) {
            for (uu = 0; uu < countof(ubx); ++uu) {
                for (rr = 0; rr < countof(rtcm); ++rr) {
                    for (cc = 0; cc < countof(cpo); ++cc) {
                        if ((nn == 1) && (uu == 1) && (rr == 1) && (cc == 1)) {
                            assert(!machine_is_stalled(nmea[nn], ubx[uu], rtcm[rr], cpo[cc]));
                        } else if ((nn != 0) && (nn != 1)) {
                            assert(!machine_is_stalled(nmea[nn], ubx[uu], rtcm[rr], cpo[cc]));
                        } else if ((uu != 0) && (uu != 1)) {
                            assert(!machine_is_stalled(nmea[nn], ubx[uu], rtcm[rr], cpo[cc]));
                        } else if ((rr != 0) && (rr != 1)) {
                            assert(!machine_is_stalled(nmea[nn], ubx[uu], rtcm[rr], cpo[cc]));
                        } else if ((cc != 0) && (cc != 1)) {
                            assert(!machine_is_stalled(nmea[nn], ubx[uu], rtcm[rr], cpo[cc]));
                        } else {
                            assert(machine_is_stalled(nmea[nn], ubx[uu], rtcm[rr], cpo[cc]));
                        }
                        ++ii;
                    }
                }
            }
        }

        assert(ii > 0);
        assert(ii == (countof(nmea) * countof(ubx) * countof(rtcm) * countof(cpo)));
    }

    return 0;
}
