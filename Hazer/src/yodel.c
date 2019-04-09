/* vi: set ts=4 expandtab shiftwidth=4: */
/**
 * @file
 *
 * Copyright 2017-2019 Digital Aggregates Corporation, Colorado, USA<BR>
 * Licensed under the terms in README.h<BR>
 * Chip Overclock (coverclock@diag.com)<BR>
 * https://github.com/coverclock/com-diag-hazer<BR>
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "com/diag/hazer/yodel.h"
#include "../src/yodel.h"

/******************************************************************************
 *
 ******************************************************************************/

static FILE * debug  = (FILE *)0;

FILE * yodel_debug(FILE * now)
{
    FILE * was;

    was = debug;
    debug = now;

    return was;
}

/******************************************************************************
 *
 ******************************************************************************/

int yodel_initialize(void)
{
    return 0;
}

int yodel_finalize(void)
{
    return 0;
}

/******************************************************************************
 *
 ******************************************************************************/

/*
 * Ublox 8, p. 134
 */
yodel_state_t yodel_machine(yodel_state_t state, int ch, void * buffer, size_t size, char ** bp, size_t * sp, size_t * lp)
{
    int done = !0;
    yodel_action_t action = YODEL_ACTION_SKIP;

    /*
     * Short circuit state machine for some characters.
     */

    switch (ch) {

    case EOF:
        DEBUG("EOF %d!\n", ch);
        state = YODEL_STATE_EOF;
        break;

    default:
        /* Do nothing. */
        break;

    }

    /*
     * Advance state machine based on stimulus.
     */

    switch (state) {

    case YODEL_STATE_EOF:
        *bp = (char *)buffer;
        *sp = 0;
        break;

    case YODEL_STATE_START:
        if (ch == YODEL_STIMULUS_SYNC_1) {
            DEBUG("UBX 0x%02x.\n", ch);
            state = YODEL_STATE_SYNC_2;
            action = YODEL_ACTION_SAVE;
            *bp = (char *)buffer;
            *sp = size;
            *lp = 0;
        }
        break;

    case YODEL_STATE_SYNC_2:
        if (ch == YODEL_STIMULUS_SYNC_2) {
            state = YODEL_STATE_CLASS;
            action = YODEL_ACTION_SAVE;
        } else {
            state = YODEL_STATE_START;
        }
        break;

    case YODEL_STATE_CLASS:
        state = YODEL_STATE_ID;
        action = YODEL_ACTION_SAVE;
        break;

    case YODEL_STATE_ID:
        state = YODEL_STATE_LENGTH_1;
        action = YODEL_ACTION_SAVE;
        break;

    case YODEL_STATE_LENGTH_1:
        /*
         * Ublox8, p. 134: "little endian"
         */
        *lp = ((unsigned)ch); /* LSB */
        DEBUG("LENGTH1 0x%02x %zu.\n", ch, *lp);
        state = YODEL_STATE_LENGTH_2;
        action = YODEL_ACTION_SAVE;
        break;

    case YODEL_STATE_LENGTH_2:
        /*
         * Ublox8, p. 134: "little endian"
         */
        *lp |= ((unsigned)ch) << 8; /* MSB */
        DEBUG("LENGTH2 0x%02x %zu.\n", ch, *lp);
        state = YODEL_STATE_PAYLOAD;
        action = YODEL_ACTION_SAVE;
        break;

    case YODEL_STATE_PAYLOAD:
        if (((*lp)--) > 1) {
            state = YODEL_STATE_PAYLOAD;
        } else {
            state = YODEL_STATE_CK_A;
        }
        action = YODEL_ACTION_SAVE;
        break;

    case YODEL_STATE_CK_A:
        state = YODEL_STATE_CK_B;
        action = YODEL_ACTION_SAVE;
        break;

    case YODEL_STATE_CK_B:
        state = YODEL_STATE_END;
        action = YODEL_ACTION_TERMINATE;
        break;

    case YODEL_STATE_END:
        DEBUG("END 0x%02x!\n", ch);
        break;

    /*
     * No default: must handle all cases.
     */

    }

    /*
     * Perform associated action.
     */

    switch (action) {

    case YODEL_ACTION_SKIP:
        DEBUG("SKIP 0x%02x?\n", ch);
        break;

    case YODEL_ACTION_SAVE:
        if ((*sp) > 0) {
            *((*bp)++) = ch;
            (*sp) -= 1;
            DEBUG("SAVE 0x%02x.\n", ch);
        } else {
            state = YODEL_STATE_START;
            DEBUG("LONG!\n");
        }
        break;

    case YODEL_ACTION_TERMINATE:
        /*
         * It seems like it's not really meaningful to NUL-terminate a binary
         * UBX packet, but it is. Doing so simplifies user code that doesn't
         * know yet the format of the data in the buffer, e.g. in the case of
         * IP datagrams. And it guarantees that we don't run off the end of
         * some UBX messages (like UBX-MON-VER) that contain null terminated
         * strings in their payloads.
         */
        if ((*sp) > 1) {
            *((*bp)++) = ch;
            (*sp) -= 1;
            DEBUG("SAVE 0x%02x.\n", ch);
            *((*bp)++) = '\0';
            (*sp) -= 1;
            DEBUG("SAVE 0x%02x.\n", '\0');
            (*sp) = size - (*sp);
        } else {
            state = YODEL_STATE_START;
            DEBUG("LONG!\n");
        }
        break;

    /*
     * No default: must handle all cases.
     */

    }

    /*
     * Done.
     */

    return state;
}

/******************************************************************************
 *
 ******************************************************************************/

/*
 * The portion of the buffer being summed includes the length, but we have
 * to compute the length first to do the checksum. Seems chicken-and-egg,
 * but I've seen the same thing in TCP headers; in fact [Ublox p. 74] says
 * this is the Fletcher checksum from RFC 1145. It refers to this as an
 * eight-bit checksum, but the result is really sixteen bits (CK_A and
 * CK_B), although it is performed eight-bits at a time on the input data.
 */
const void * yodel_checksum(const void * buffer, size_t size, uint8_t * ck_ap, uint8_t * ck_bp)
{
    const void * result = (void *)0;
    const uint8_t * bp = (const uint8_t *)buffer;
    uint8_t ck_a = 0;
    uint8_t ck_b = 0;
    uint16_t length = 0;

    /*
     * Ublox8, p. 134: "little endian"
     */
    length = ((uint8_t)(bp[YODEL_UBX_LENGTH_MSB])) << 8;
    length |= ((uint8_t)(bp[YODEL_UBX_LENGTH_LSB]));
    length += YODEL_UBX_SUMMED;

#if 0
    fprintf(stderr, "YODEL_CHECKSUM 0x%x 0x%x 0x%x 0x%x 0x%lx\n", bp[YODEL_UBX_LENGTH_MSB], bp[YODEL_UBX_LENGTH_LSB], YODEL_UBX_SUMMED, length, size);
#endif

    if ((length + YODEL_UBX_UNSUMMED) <= size) {

        for (bp += YODEL_UBX_CLASS; length > 0; --length) {
            ck_a += *(bp++);
            ck_b += ck_a;
        }

        *ck_ap = ck_a;
        *ck_bp = ck_b;

        result = bp;

    }

    return (const void *)bp;
}

ssize_t yodel_length(const void * buffer, size_t size)
{
       ssize_t result = -1;
       uint16_t length = 0;
       const unsigned char * sentence = (const char *)0;

       sentence = (const char *)buffer;

       if (size < YODEL_UBX_SHORTEST) {
           /* Do nothing. */
       } else if (sentence[YODEL_UBX_SYNC_1] != YODEL_STIMULUS_SYNC_1) {
           /* Do nothing. */
       } else if (sentence[YODEL_UBX_SYNC_2] != YODEL_STIMULUS_SYNC_2) {
           /* Do nothing. */
       } else {
           /*
            * Ublox8, p. 134: "little endian"
            */
           length = sentence[YODEL_UBX_LENGTH_MSB] << 8;
           length |= sentence[YODEL_UBX_LENGTH_LSB];
           if (length > (size - YODEL_UBX_SHORTEST)) {
               /* Do nothing. */
           } else {
               result = length;
               result += YODEL_UBX_SHORTEST;
           }
       }

       return result;
}

/******************************************************************************
 *
 ******************************************************************************/

int yodel_ubx_mon_hw(yodel_ubx_mon_hw_t * mp, const void * bp, ssize_t length)
{
    int rc = -1;
    const unsigned char * hp = (const unsigned char *)bp;

    if (hp[YODEL_UBX_CLASS] != YODEL_UBX_MON_HW_Class) {
        /* Do nothing. */
    } else if (hp[YODEL_UBX_ID] != YODEL_UBX_MON_HW_Id) {
        /* Do nothing. */
    } else if (length != (YODEL_UBX_SHORTEST + YODEL_UBX_MON_HW_Length)) {
        /* Do nothing. */
    } else {
        memcpy(mp, &(hp[YODEL_UBX_PAYLOAD]), sizeof(*mp));
        COM_DIAG_YODEL_LETOH(mp->pinSel);
        COM_DIAG_YODEL_LETOH(mp->pinBank);
        COM_DIAG_YODEL_LETOH(mp->pinDir);
        COM_DIAG_YODEL_LETOH(mp->pinVal);
        COM_DIAG_YODEL_LETOH(mp->noisePerMS);
        COM_DIAG_YODEL_LETOH(mp->agcCnt);
        COM_DIAG_YODEL_LETOH(mp->usedMask);
        COM_DIAG_YODEL_LETOH(mp->pinIrq);
        COM_DIAG_YODEL_LETOH(mp->pullH);
        COM_DIAG_YODEL_LETOH(mp->pullL);
        rc = 0;
    }

    return rc;
}

int yodel_ubx_nav_status(yodel_ubx_nav_status_t * mp, const void * bp, ssize_t length)
{
    int rc = -1;
    const unsigned char * hp = (const unsigned char *)bp;

    if (hp[YODEL_UBX_CLASS] != YODEL_UBX_NAV_STATUS_Class) {
        /* Do nothing. */
    } else if (hp[YODEL_UBX_ID] != YODEL_UBX_NAV_STATUS_Id) {
        /* Do nothing. */
    } else if (length != (YODEL_UBX_SHORTEST + YODEL_UBX_NAV_STATUS_Length)) {
        /* Do nothing. */
    } else {
        memcpy(mp, &(hp[YODEL_UBX_PAYLOAD]), sizeof(*mp));
        COM_DIAG_YODEL_LETOH(mp->iTOW);
        COM_DIAG_YODEL_LETOH(mp->ttff);
        COM_DIAG_YODEL_LETOH(mp->msss);
        rc = 0;
    }

    return rc;
}

int yodel_ubx_ack(yodel_ubx_ack_t * mp, const void * bp, ssize_t length)
{
    int rc = -1;
    const unsigned char * hp = (const unsigned char *)bp;

    if (hp[YODEL_UBX_CLASS] != YODEL_UBX_ACK_Class) {
        /* Do nothing. */
    } else if ((hp[YODEL_UBX_ID] != YODEL_UBX_ACK_ACK_Id) && (hp[YODEL_UBX_ID] != YODEL_UBX_ACK_NAK_Id)) {
        /* Do nothing. */
    } else if (length != (YODEL_UBX_SHORTEST + YODEL_UBX_ACK_Length)) {
        /* Do nothing. */
    } else {
        memcpy(mp, &(hp[YODEL_UBX_PAYLOAD]), YODEL_UBX_ACK_Length);
        mp->state = (hp[YODEL_UBX_ID] == YODEL_UBX_ACK_ACK_Id);
        rc = 0;
    }

    return rc;
}

int yodel_ubx_cfg_valget(const void * bp, ssize_t length)
{
    int rc = -1;
    const unsigned char * hp = (const unsigned char *)bp;

    if (hp[YODEL_UBX_CLASS] != YODEL_UBX_CFG_VALGET_Class) {
        /* Do nothing. */
    } else if (hp[YODEL_UBX_ID] != YODEL_UBX_CFG_VALGET_Id) {
        /* Do nothing. */
    } else if (length < (YODEL_UBX_SHORTEST + YODEL_UBX_CFG_VALGET_Length)) {
        /* Do nothing. */
    } else {
        rc = 0;
    }

    return rc;
}

int yodel_ubx_mon_ver(const void * bp, ssize_t length)
{
    int rc = -1;
    const unsigned char * hp = (const unsigned char *)bp;

    if (hp[YODEL_UBX_CLASS] != YODEL_UBX_MON_VER_Class) {
        /* Do nothing. */
    } else if (hp[YODEL_UBX_ID] != YODEL_UBX_MON_VER_Id) {
        /* Do nothing. */
    } else {
        rc = 0;
    }

    return rc;
}

int yodel_ubx_rxm_rtcm(yodel_ubx_rxm_rtcm_t * mp, const void * bp, ssize_t length)
{
    int rc = -1;
    const unsigned char * hp = (const unsigned char *)bp;

    if (hp[YODEL_UBX_CLASS] != YODEL_UBX_RXM_RTCM_Class) {
        /* Do nothing. */
    } else if (hp[YODEL_UBX_ID] != YODEL_UBX_RXM_RTCM_Id) {
        /* Do nothing. */
    } else if (length != (YODEL_UBX_SHORTEST + YODEL_UBX_RXM_RTCM_Length)) {
        /* Do nothing. */
    } else {
        memcpy(mp, &(hp[YODEL_UBX_PAYLOAD]), sizeof(*mp));
        rc = 0;
    }

    return rc;
}

int yodel_ubx_nav_svin(yodel_ubx_nav_svin_t * mp, const void * bp, ssize_t length)
{
    int rc = -1;
    const unsigned char * hp = (const unsigned char *)bp;

    if (hp[YODEL_UBX_CLASS] != YODEL_UBX_NAV_SVIN_Class) {
        /* Do nothing. */
    } else if (hp[YODEL_UBX_ID] != YODEL_UBX_NAV_SVIN_Id) {
        /* Do nothing. */
    } else if (length != (YODEL_UBX_SHORTEST + YODEL_UBX_NAV_SVIN_Length)) {
        /* Do nothing. */
    } else {
        memcpy(mp, &(hp[YODEL_UBX_PAYLOAD]), sizeof(*mp));
        rc = 0;
    }

    return rc;
}
