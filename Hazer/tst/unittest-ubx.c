/* vi: set ts=4 expandtab shiftwidth=4: */
/**
 * @file
 *
 * Copyright 2018 Digital Aggregates Corporation, Colorado, USA<BR>
 * Licensed under the terms in README.h<BR>
 * Chip Overclock (coverclock@diag.com)<BR>
 * https://github.com/coverclock/com-diag-hazer<BR>
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>
#if !defined(_BSD_SOURCE)
#define _BSD_SOURCE
#endif
#include <endian.h>
#include "com/diag/hazer/hazer.h"
#include "com/diag/hazer/yodel.h"
#include "com/diag/diminuto/diminuto_escape.h"
#include "com/diag/diminuto/diminuto_dump.h"

#define BEGIN(_MESSAGE_) \
	do { \
		const char * string = (const char *)0; \
		size_t length = 0; \
		char * message = (char *)0; \
		size_t size = 0; \
		string = (_MESSAGE_); \
		length = strlen(string) + 1; \
		message = (char *)malloc(length); \
		size = diminuto_escape_collapse(message, string, length); \
		size -= 1; \
		do { \
			(void)0

#define END \
		} while (0); \
		free(message); \
	} while (0)


int main(void)
{

    /**************************************************************************/

    {
        assert(sizeof(yodel_ubx_header_t) == (YODEL_UBX_UNSUMMED + YODEL_UBX_SUMMED));
        assert(sizeof(yodel_ubx_mon_hw_t) == YODEL_UBX_MON_HW_Length);
        assert(sizeof(yodel_ubx_nav_status_t) == YODEL_UBX_NAV_STATUS_Length);
        assert(sizeof(yodel_ubx_ack_t) == (YODEL_UBX_ACK_Length + sizeof(uint8_t)));
        assert(sizeof(yodel_ubx_cfg_valget_t) == YODEL_UBX_CFG_VALGET_Length);
        assert(sizeof(yodel_ubx_nav_svin_t) == YODEL_UBX_NAV_SVIN_Length);
        assert(sizeof(yodel_ubx_nav_status_t) == YODEL_UBX_NAV_STATUS_Length);
        assert(sizeof(yodel_ubx_rxm_rtcm_t) == YODEL_UBX_RXM_RTCM_Length);
    }

    /**************************************************************************/

    {
        yodel_ubx_header_t header = { 0 };
        unsigned char * buffer;

        buffer = (unsigned char *)&header;

        buffer[YODEL_UBX_SYNC_1] = YODEL_STIMULUS_SYNC_1;
        buffer[YODEL_UBX_SYNC_2] = YODEL_STIMULUS_SYNC_2;
        buffer[YODEL_UBX_CLASS] = 0x11;
        buffer[YODEL_UBX_ID] = 0x22;
        buffer[YODEL_UBX_LENGTH_LSB] = 0x33;
        buffer[YODEL_UBX_LENGTH_MSB] = 0x44;

        assert(header.sync_1 == YODEL_STIMULUS_SYNC_1);
        assert(header.sync_2 == YODEL_STIMULUS_SYNC_2);
        assert(header.class == 0x11);
        assert(header.id == 0x22);
        assert(le16toh(header.length) == 0x4433);
    }

    /**************************************************************************/

    {
        union { uint64_t integer; uint8_t byte[sizeof(uint64_t)]; } u64 = { 0x1122334455667788ULL };
        union { uint32_t integer; uint8_t byte[sizeof(uint32_t)]; } u32 = { 0x11223344UL };
        union { uint16_t integer; uint8_t byte[sizeof(uint16_t)]; } u16 = { 0x1122U };
        union { uint8_t  integer; uint8_t byte[sizeof(uint8_t)];  } u8 =  { 0x11U };

#if __BYTE_ORDER == __LITTLE_ENDIAN
        assert(u64.byte[0] == 0x88);
        assert(u32.byte[0] == 0x44);
        assert(u16.byte[0] == 0x22);
        assert(u8.byte[0]  == 0x11);
#else
        assert(u64.byte[0] == 0x11);
        assert(u32.byte[0] == 0x11);
        assert(u16.byte[0] == 0x11);
        assert(u8.byte[0]  == 0x11);
#endif

        COM_DIAG_YODEL_LETOH(u64.integer);
        COM_DIAG_YODEL_LETOH(u32.integer);
        COM_DIAG_YODEL_LETOH(u16.integer);
        COM_DIAG_YODEL_LETOH(u8.integer );

        assert(u64.byte[0] == 0x88);
        assert(u32.byte[0] == 0x44);
        assert(u16.byte[0] == 0x22);
        assert(u8.byte[0]  == 0x11);
    }

    /**************************************************************************/

    BEGIN("\\xb5b\\x05\\x00\\x02\\0\\x06\\x8a\\x98\\xc1");
    	yodel_ubx_ack_t data = YODEL_UBX_ACK_INITIALIZER;
    	fprintf(stderr, "\"%s\"[%zu]\n", string, length);
    	diminuto_dump(stderr, message, size);
    	assert(yodel_ubx_ack(&data, message, size) == 0);
    	assert(data.state == 0);
    END;

    BEGIN("\\xb5b\\x05\\x01\\x02\\0\\x06\\x8b\\x99\\xc2");
		yodel_ubx_ack_t data = YODEL_UBX_ACK_INITIALIZER;
    	fprintf(stderr, "\"%s\"[%zu]\n", string, length);
    	diminuto_dump(stderr, message, size);
		assert(yodel_ubx_ack(&data, message, size) == 0);
		assert(data.state == !0);
    END;

    BEGIN("\\xb5b\\x06\\x8b\\f\\0\\x01\\0\\0\\0\\x11\\0\\x03@\\xa0\\x86\\x01\\0\\x19'");
    	yodel_ubx_cfg_valget_t data = YODEL_UBX_CFG_VALGET_INITIALIZER;
    	fprintf(stderr, "\"%s\"[%zu]\n", string, length);
    	diminuto_dump(stderr, message, size);
    	assert(yodel_ubx_cfg_valget(message, size) == 0);
    END;

    BEGIN("\\xb5b\\x06\\x8b\\t\\0\\x01\\0\\0\\0\\xbf\\x02\\x91 \\x01\\x0e\\xf5");
		yodel_ubx_cfg_valget_t data = YODEL_UBX_CFG_VALGET_INITIALIZER;
		fprintf(stderr, "\"%s\"[%zu]\n", string, length);
		diminuto_dump(stderr, message, size);
		assert(yodel_ubx_cfg_valget(message, size) == 0);
    END;

    BEGIN("\\xb5b\\n\\t<\\0\\xc1\\x81\\0\\0\\0\\0\\x01\\0\\0\\x80\\0\\0\\xdfg\\0\\0L\\0\\x91\\x14\\x01\\x02\\x01\\x85\\xbe\\xff\\x01\\0\\xff\\0\\x01\\x03\\x02\\x10\\xff\\x12\\x13\\x14\\x15\\x0e\\n\\v\\x0fD\\x16\\x05\\xeeZ\\0\\0\\0\\0\\xdb{\\0\\0\\0\\0\\0\\0!M");
    	yodel_ubx_mon_hw_t data = YODEL_UBX_MON_HW_INITIALIZER;
		fprintf(stderr, "\"%s\"[%zu]\n", string, length);
		diminuto_dump(stderr, message, size);
		assert(yodel_ubx_mon_hw(&data, message, size) == 0);
    END;

    BEGIN("\\xb5b\\n\\x04\\xdc\\0EXT CORE 1.00 (94e56e)\\0\\0\\0\\0\\0\\0\\0\\000190000\\0\\0ROM BASE 0x118B2060\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0FWVER=HPG 1.11\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0PROTVER=27.10\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0MOD=ZED-F9P\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0GPS;GLO;GAL;BDS\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0QZSS\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\x9au");
		fprintf(stderr, "\"%s\"[%zu]\n", string, length);
		diminuto_dump(stderr, message, size);
    	assert(yodel_ubx_mon_ver(message, size) == 0);
    END;

    BEGIN("\\xb5b\\x01\\x03\\x10\\0h\\x15i\\x0f\\x05\\xdd\\0\\bkn\\0\\0\\xde\\x1e\\xbf\\0\\x87V");
		yodel_ubx_nav_status_t data = YODEL_UBX_NAV_STATUS_INITIALIZER;
		fprintf(stderr, "\"%s\"[%zu]\n", string, length);
		diminuto_dump(stderr, message, size);
		assert(yodel_ubx_nav_status(&data, message, size) == 0);
    END;

    BEGIN("\\xb5b\\x01;(\\0\\0\\0\\0\\0\\xf8\\x83\\xac\\x0e<\\0\\0\\0\\xb7\\x14Z\\xf8hh\\xc2\\xe3\\x8ai5\\x18\\xe9\\xf1\\xf2\\0\\xe6\\x1a\\x01\\0=\\0\\0\\0\\x01\\0\\0\\0\\xb2\\x1f");
		yodel_ubx_nav_svin_t data = YODEL_UBX_NAV_SVIN_INITIALIZER;
		fprintf(stderr, "\"%s\"[%zu]\n", string, length);
		diminuto_dump(stderr, message, size);
		assert(yodel_ubx_nav_svin(&data, message, size) == 0);
    END;

    BEGIN("\\xb5b\\x022\\b\\0\\x02\\0\\0\\0\\0\\0\\xce\\x04\\x10>");
		yodel_ubx_rxm_rtcm_t data = YODEL_UBX_RXM_RTCM_INITIALIZER;
		fprintf(stderr, "\"%s\"[%zu]\n", string, length);
		diminuto_dump(stderr, message, size);
		assert(yodel_ubx_rxm_rtcm(&data, message, size) == 0);
    END;

    /**************************************************************************/

    return 0;
}
