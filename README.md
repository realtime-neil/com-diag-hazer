com-diag-hazer
==============

Parse NMEA strings from GPS devices.

[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/coverclock)

# Copyright

Copyright 2017-2018 by the Digital Aggregates Corporation, Colorado, USA.

# License

Licensed under the terms in LICENSE.txt. 

# Abstract

This software is an original work of its author(s).

This file is part of the Digital Aggregates Corporation Hazer
package. Hazer is a simple C-based parser of the NMEA (National Marine
Electronics Association) 0183 4.10 strings produced by most Global
Positioning System (GPS) devices.  Unlike the Drover project, Hazer does
its own NMEA parsing.  Hazer includes a gpstool utility to display the
interpreted GPS data. gpstool accepts NMEA sentences from standard input,
from a serial(ish) device, or from a UDP socket.

The latest version of Hazer includes the ability to recognize binary output in
UBX format, a proprietary data format generated by U-Blox devices. UBX is
supported by a parallel stack called Yodel that is included in  the Hazer
distribution. gpstool uses both the Hazer stack and the Yodel stack to process
both NMEA and UBX messages interleaved in the same input stream.

If you're wondering why I don't use the excellent open source GPS daemon
(gpsd) and its GPS monitor (gpsmon), the answer is: I have, in many projects,
typically in conjunction with the open source NTPsec daemon (ntpd). Hazer was
developed as an excuse for me to learn in detail more about how GPS works and
how NMEA and UBX sentences are formatted (because I only learn by doing), and
also to develop an NMEA and UBX parsing library that I can incorporate into
the kinds of embedded systems I am frequently called to work upon. Hazer and
gpstool have also turned out to be really useful tools for testing and
evaluating GPS devices.

# Sentences

Hazer parses the following NMEA sentences.

* GGA - Global Positioning System Fix Data (NMEA 0183 Version 4.10 p. 68)
* GLL - Geographic Position - Latitude/Longitude (NMEA 0183 Version 4.10 p. 87)
* GSA - GNSS DOP and Active Satellites (NMEA 0183 Version 4.10 p. 92)
* GSV - GNSS Satellites In View (NMEA 0183 Version 4.10 p. 96)
* RMC - Recommended Minimum Specific GNSS Data (NMEA 0183 Version 4.10 p. 113)
* TXT - Text Transmission (NMEA 0183 Version 4.10 p. 124)
* VTG - Course Over Ground & Ground Speed (NMEA 0183 Version 4.10 p. 127)

# Talkers

Hazer recognizes the following talkers as belonging to the corresponding
constellations and systems.

These talkers have been observed in the wild coming from actual GPS receivers.

* GL - GLObal NAvigation Satellite System (GLONASS) - Russia
* GN - Global Navigation Satellite System (GNSS) - Generic
* GP - Global Positioning System (GPS, formerly NavStar) - USA

Support for these talkers has been unit tested but has never been exercised
using actual GPS receivers.

* GA - Galileo (as in Galileo Galilei) - EU
* BD - BeiDou (as in The Big Dipper) - China
* GB - BeiDou (as in The Big Dipper) - China
* QZ - Quasi-Zenith Satellite System (QZSS) - Japan

# Identifiers

Hazer recognizes the following satellite identifiers in the GSA and GSV
messages.

These satellite identifiers have been observed in the wild coming from actual
GPS receivers.

* GPS - 1..32
* SBAS - 33..34
* GLONASS - 65..96

Support for these satellite identifiers has been unit tested but has never been
exercised using actual GPS receivers.

* QZSS - 193..200
* BeiDou - 201..235

There is currently no defined or proposed satellite identifiers for Galileo.

# Devices

Hazer has been successfully tested with the following GPS chipsets.

* Quectel L80-R    
* SiRF Star II    
* SiRF Star III    
* SiRF Star IV    
* U-Blox 6    
* U-Blox 7    
* U-Blox 8    

Hazer has been successfully tested with the following serial-to-USB chipsets
used by GPS devices.

* Cygnal Integrated Products    
* FTDI    
* Prolific    
* U-Blox (apparently integrated into the GPS chip itself)    

Hazer has been successfully tested with the following GPS devices.

* GlobalSat BU-353S4 (SiRF Star IV/Prolific, 4800 8N1, v067Bp2303, ttyUSB, 1Hz) [0] [1]    
* GlobalSat ND-105C (SiRF Star III/Prolific, 4800 8N1, v067Bp2303, ttyUSB, 1Hz) [0]    
* GlobalSat BU-353S4-5Hz (SiRF Star IV/Prolific, 115200 8N1, v067Bp2303, ttyUSB, 5Hz) [0]   
* Stratux Vk-162 Gmouse (U-Blox 7, 9600 8N1, v1546p01A7, ttyACM, 1Hz) [2]    
* Eleduino Gmouse (U-Blox 7, 9600 8N1, v1546p01A7, ttyACM, 1Hz) [2]    
* Generic Gmouse (U-Blox 7, 9600 8N1, v1546p01A7, ttyACM, 1Hz) [2]    
* Pharos GPS-360 (SiRF Star II/Prolific, 4800 8N1, v067BpAAA0, ttyUSB, 1Hz) [3]    
* Pharos GPS-500 (SiRF Star III/Prolific, 4800 8N1, v067BpAAA0, ttyUSB, 1Hz) [3]    
* MakerFocus USB-Port-GPS (Quectel L80-R/Cygnal, 9600 8N1, v10C4pEA60, ttyUSB, 1Hz) [2] [6]    
* Sourcingbay GM1-86 (U-Blox 7, 9600 8n1, p1546v01A7, ttyACM, 1Hz) [2]    
* Uputronics Raspberry Pi GPS Expansion Board v4.1 (U-Blox M8, 9600 8n1, N/A, ttyAMA, 1Hz) [4]    
* Jackson Labs Technologies CSAC GPSDO (U-Blox LEA-6T, 115200 8n1, N/A, ttyACM, 1Hz)    
* Garmin GLO (unknown, Bluetooth, N/A, rfcomm, 10Hz) [4]    
* NaviSys GR-701W (U-Blox 7/Prolific, 9600 8N1, v067Bp2303, ttyUSB, 1Hz) [5] [7] [8]    
* TOPGNSS GN-803G (U-Blox UBX-M8030-KT, 9600 8N1, v1546p01a8, ttyACM, 1Hz) [2] [4] [8]    
* GlobalSat BU-353W10 (U-Blox UBX-M8030, 9600 8N1, v1546p01a8, ttyACM, 1Hz) [0] [2] [4] [8]

Footnotes:

[0] GlobalSat is the company formerly known as USGlobalSat.    
[1] An excellent all around GPS receiver easily acquired from numerous outlets.    
[2] Emits all sorts of interesting stuff in unsolicited $GPTXT or $GNTXT sentences.    
[3] Install udev rules in overlay to prevent ModemManager from toying with device.    
[4] Receives GPS (U.S., formerly "Navstar") *and* GLONASS (Russian) constellations concurrently.    
[5] Receives GPS (U.S.) *or* GLONASS (Russian) constellations via configuration.    
[6] Supports One Pulse Per Second (1PPS) by toggling digital output pin.    
[7] Supports One Pulse Per Second (1PPS) by toggling Data Carrier Detect (DCD).    
[8] Supports UBX.

# Platforms

Various releases of Hazer have been tested on one or more the following targets
and platforms.

"Mercury"    
Dell OptiPlex 7040    
Intel Core i7-6700T @ 2.8GHz x 4 x 2    
Ubuntu 14.04.4 "Trusty Tahr"    
Linux 4.2.0    
gcc 4.8.4    

"Nickel"    
Intel NUC5i7RYH    
Intel Core i7-5557U @ 3.10GHz x 2 x 2    
Ubuntu 16.04.2 "Xenial Xerus"    
Linux 4.10.0    
gcc 5.4.0    

"Nickel" (updated)    
Intel NUC5i7RYH    
Intel Core i7-5557U @ 3.10GHz x 2 x 2    
Ubuntu 18.04 "Bionic Beaver"    
Linux 4.15.0    
gcc 7.3.0    

"Bronze"    
Raspberry Pi 2 Model B    
Broadcom BCM2836 Cortex-A7 ARMv7 @ 900MHz x 4    
Raspbian 8.0 "Jessie"    
Linux 4.4.34    
gcc 4.9.2    

"Zinc" or "Lead"    
Raspberry Pi 3 Model B    
Broadcom BCM2837 Cortex-A53 ARMv7 @ 1.2GHz x 4    
Raspbian 8.0 "Jessie"    
Linux 4.4.34    
gcc 4.9.2    

"Gold"    
Raspberry Pi 3 Model B+    
Broadcom BCM2837B0 Cortex-A53 ARMv7 @ 1.4GHz x 4    
Raspbian 9.4 "Stretch"    
Linux 4.14.34    
gcc 6.3.0    

# Contact

Chip Overclock    
Digital Aggregates Corporation    
3440 Youngfield Street, Suite 209    
Wheat Ridge CO 80033 USA    
http://www.diag.com    
mailto:coverclock@diag.com    

# Repositories

<https://github.com/coverclock/com-diag-hazer>

<https://github.com/coverclock/com-diag-diminuto>

# Media

<https://flic.kr/s/aHskRMLrx7>

<https://youtu.be/UluGfpqpiQw>

<https://youtu.be/ZXT_37PvmhE>

# Articles

<https://coverclock.blogspot.com/2018/08/practical-geolocation-ii.html>

<https://coverclock.blogspot.com/2018/08/practical-geolocation.html>

<https://coverclock.blogspot.com/2018/04/a-menagerie-of-gps-devices-with-usb.html>

<https://coverclock.blogspot.com/2017/09/time-space.html>

<http://coverclock.blogspot.com/2017/02/better-never-than-late.html>

# Resources

<http://www.catb.org/gpsd/NMEA.txt>

<https://support.google.com/earth/answer/148095>

<http://earth.google.com/intl/ar/userguide/v4/index.htm>

<http://static.googleusercontent.com/media/earth.google.com/en//userguide/v4/google_earth_user_guide.pdf>

<https://support.google.com/earth/answer/168344>

<https://dl.google.com/earth/client/GE7/release_7_1_8/googleearth-pro-7.1.8.3036.dmg>

<https://support.google.com/maps/answer/18539>

<https://fossies.org/linux/misc/gpsd-3.17.tar.gz/gpsd-3.17/test/daemon/beidou-gb.log>

<http://ktuukkan.github.io/marine-api/0.9.0/javadoc/net/sf/marineapi/nmea/sentence/TalkerId.html>

<https://github.com/mvglasow/satstat/wiki/NMEA-IDs>

<https://pilotweb.nas.faa.gov/PilotWeb/noticesAction.do?queryType=ALLGPS&formatType=ICAO>

# Build

Clone and build Diminuto (used by gpstool although not by libhazer).

    cd ~
    mkdir -p src
    cd src
    git clone https://github.com/coverclock/com-diag-diminuto
    cd com-diag-diminuto/Diminuto
    make pristine depend all

Clone and build Hazer.

    cd ~
    mkdir -p src
    cd src
    git clone https://github.com/coverclock/com-diag-hazer
    cd com-diag-hazer/Hazer
    make pristine depend all

Set up environment and run tests and utilities.

    cd ~/src/com-diag-hazer/Hazer
    . out/host/bin/setup
    unittest-checksum
    unittest-format
    unittest-nmea
    unittest-parse
    unittest-tokenize
    gpstool -?

Optionally install Diminuto and Hazer in /usr/local.

    cd ~/src/com-diag-diminuto/Diminuto
    sudo make install
    cd ~/src/com-diag-hazer/Hazer
    sudo make install

# Directories
 
* bin - utility source files.
* cfg - configuration makefiles.
* dat - NMEA and UBX output captured from actual receivers.
* fun - functional test source files.
* inc - public header files.
* out - build artifacts.
* fs - file system overlay that may be useful on the host on which Hazer runs.
* src - feature implementation and private header source files.
* tst - unit test source files (does not require a GPS receiver).

# Utilities

* consumer - uses gpstool to consume NMEA etc. datagrams and report on stdout.    
* gpstool - C program that uses Diminuto and Hazer and implements scripts.    
* hazerclient - MacOS file to run Google Maps API in Firefox browser.    
* hazer - uses gpstool to consume NMEA etc. from serial port and report on stdout.    
* pps - uses Diminuto pintool to multiplex on a 1PPS GPIO pin.    
* producer - uses gpstool to consume NMEA etc. from serial port and forward as datagrams.    
* provider - uses gpstool to conume NMEA etc. datagrams and forward to serial port.    

# Functional Tests

* bu353s4 - script that uses gpstool to exercise the GlobalSat BU-353S4 receiver.
* bu353w10 - script that uses gpstool to exercise the GlobalSat BU-353W10 receiver.
* bu353w10slow - script that uses gpstool to exercise the GlobalSat BU-353W10 receiver with slow displays.
* gn803g - script that uses gpstool to exercise the TOPGNSS GN-803G receiver.
* gr701w - script that uses gpstool to exercise the NaviSys GR701W receiver.    
* sirfstar4 - script that uses gpstool to exercise any SiRF Star 4 device.
* talkers - script that uses gpstool to process a file of synthetic input.
* ublox7 - script that uses gpstool to exercise any Ublox 7 device.    
* ublox8 - script that uses gpstool to exercise any Ublox 8 device.

# Help

    > gpstool -?

    usage: gpstool [ -d ] [ -v ] [ -V ] [ -D DEVICE ] [ -b BPS ] [ -7 | -8 ]  [ -e | -o | -n ] [ -1 | -2 ] [ -l | -m ] [ -h ] [ -s ] [ -I PIN ] [ -c ] [ -p PIN ] [ -W NMEA ] [ -R | -E | -F ] [ -A ADDRESS ] [ -P PORT ] [ -O ] [ -L FILE ] [ -t SECONDS ] [ -C ]
           -1          Use one stop bit for DEVICE.
           -2          Use two stop bits for DEVICE.
           -4          Use IPv4 for ADDRESS, PORT.
           -6          Use IPv6 for ADDRESS, PORT.
           -7          Use seven data bits for DEVICE.
           -8          Use eight data bits for DEVICE.
           -A ADDRESS  Send sentences to ADDRESS.
           -C          Ignore bad checksums.
           -D DEVICE   Use DEVICE.
           -E          Like -R but use ANSI escape sequences.
           -F          Like -E but refresh at 1Hz.
           -I PIN      Take 1PPS from GPIO input PIN (requires -D).
           -L FILE     Log sentences to FILE.
           -O          Output sentences to DEVICE.
           -P PORT     Send to or receive from PORT.
           -R          Print a report on standard output.
           -W NMEA     Collapse escapes, append checksum, and write to DEVICE.
           -V          Print release, vintage, and revision on standard output.
           -b BPS      Use BPS bits per second for DEVICE.
           -c          Take 1PPS from DCD (requires -D and implies -m).
           -d          Display debug output on standard error.
           -e          Use even parity for DEVICE.
           -l          Use local control for DEVICE.
           -m          Use modem control for DEVICE.
           -o          Use odd parity for DEVICE.
           -p PIN      Assert GPIO output PIN with 1PPS (requires -D and -I or -c).
           -n          Use no parity for DEVICE.
           -h          Use RTS/CTS for DEVICE.
           -r          Reverse use of standard output and standard error.
           -s          Use XON/XOFF for DEVICE.
           -t SECONDS  Expire GNSS data after SECONDS seconds.
           -v          Display verbose output on standard error.

# Dependencies

The Hazer library itself is standlone other than the usual standard
C and POSIX libraries. But the gpstool is also built on top of the
Digital Aggretates Corporation Diminuto library. Diminuto is a general
purpose C-based systems programming library that supports serial
port configuration, socket-based communication, and a passle of other
useful stuff. If you don't build Diminuto where the Makefile expects it, some
minor Makefile hacking might be required.

# Display

When using the -E option with gpstool, so that it uses ASCII escape sequences
to do cursor control for its report on standard output, as this example does
when using the BU-353W10 receiver,

    > gpstool -D devttyACM0 -b 9600 -8 -n -1 -E -t 10

the display looks something like this snapshot as it is continually updated.
(In this and most other output, the asterisk \* is used to mean the degree
symbol. This should not be confused with its use as a delimeter in NMEA
sentences.)

    INP $GLGSV,3,3,11,84,31,242,35,85,29,307,32,,,,38*61\r\n
    OUT $PUBX,40,VTG,0,0,0,1,0,0
    LOC 2018-11-12T14:09:57.056661083-07:00+00J (9.1.0)
    TIM 2018-11-12T21:09:57Z 0pps                                   10secs GNSS
    POS 39*47'39.01"N, 105*09'12.29"W   39.794170, -105.153415      10secs GNSS
    ALT    5637.40'   1718.300m                                     10secs GNSS
    COG N    0.000*T   0.000*M                                      10secs GNSS
    SOG      0.037mph      0.032knots      0.060kph                 10secs GNSS
    INT GGA [12] dmy 1 inc 1 (  9 10  5  0  0  4  4 )               10secs GNSS
    ACT {  10  32  18  11  31  20   1  12  25  22  51  48 } [12]    10secs GPS
    ACT {  78  80  79  85  84  68  69                     } [07]    10secs GLONASS
    DOP   1.25pdop   0.62hdop   1.09vdop                            10secs GPS
    DOP   1.25pdop   0.62hdop   1.09vdop                            10secs GLONASS
    SAT [01] id   1 elv  28* azm  312* snr  28dBHz                  10secs GPS
    SAT [02] id   8 elv   4* azm  248* snr  28dBHz                  10secs GPS
    SAT [03] id  10 elv  49* azm  103* snr  35dBHz                  10secs GPS
    SAT [04] id  11 elv  27* azm  290* snr  26dBHz                  10secs GPS
    SAT [05] id  12 elv   9* azm   59* snr  17dBHz                  10secs GPS
    SAT [06] id  14 elv  74* azm  304* snr  21dBHz                  10secs GPS
    SAT [07] id  18 elv  48* azm  284* snr  35dBHz                  10secs GPS
    SAT [08] id  20 elv  22* azm  118* snr  32dBHz                  10secs GPS
    SAT [09] id  22 elv  18* azm  303* snr  28dBHz                  10secs GPS
    SAT [10] id  25 elv  14* azm   93* snr  11dBHz                  10secs GPS
    SAT [11] id  31 elv  44* azm  180* snr  44dBHz                  10secs GPS
    SAT [12] id  32 elv  69* azm   25* snr  31dBHz                  10secs GPS
    SAT [13] id  46 elv  38* azm  215* snr  39dBHz                  10secs GPS
    SAT [14] id  48 elv  36* azm  220* snr  39dBHz                  10secs GPS
    SAT [15] id  51 elv  44* azm  183* snr  42dBHz                  10secs GPS
    SAT [16] id  68 elv  33* azm   70* snr  31dBHz                  10secs GLONASS
    SAT [17] id  69 elv  57* azm  357* snr  36dBHz                  10secs GLONASS
    SAT [18] id  70 elv  19* azm  295* snr  21dBHz                  10secs GLONASS
    SAT [19] id  77 elv   0* azm   17* snr  19dBHz                  10secs GLONASS
    SAT [20] id  78 elv  35* azm   52* snr   9dBHz                  10secs GLONASS
    SAT [21] id  79 elv  47* azm  107* snr  22dBHz                  10secs GLONASS
    SAT [22] id  80 elv  11* azm  171* snr  36dBHz                  10secs GLONASS
    SAT [23] id  83 elv   0* azm  196* snr   0dBHz                  10secs GLONASS
    SAT [24] id  84 elv  31* azm  242* snr  35dBHz                  10secs GLONASS
    SAT [25] id  85 elv  29* azm  307* snr  32dBHz                  10secs GLONASS

INP is the most recent data read from the device, either NMEA sentences or
UBX packets, with binary data converted into standard C escape sequences.

OUT is the most recent data written to the device, as specified on the command
line using the -W option.

LOC is the current local time provided by the host system, and the revision
number of this version of Hazer. The local (or 'J' for "Juliet") time includes
the time zone offset from UTC in hours and minutes, and the current daylight
saving time (DST) offset in hours.

All subsequent lines represent the current state of Hazer data structures
updated by data read from the device. Each line includes at its end the
number of seconds left before this data expires because it has not been updated
by the device, and the system (satellite constellation) with which it is
associated. GNSS indicates that the device is computing an "ensemble" solution
that uses transmissions from multiple constellations, for example, from both
the U.S. GPS constellation and the Russian GLONASS constellation.

TIM is the most recent time solution, in UTC (or 'Z' for "Zulu"), and the
current value of the One Pulse Per Second (1PPS) signal if the device provides
it and it was enabled on the command line using -c (using data carrier detect
or DCD) or -I (using general purpose input/output or GPIO).

POS is the most recent position solution, latitude and longitude, in degrees,
hours, minutes, and decimal seconds, and in decimal degrees. The latter format
can be cut and pasted directly into Google Maps and Google Earth.

ALT is the most recent altitude solution, in feet and meters.

COG is the most recent course over ground solution, in cardinal compass
direction, and the bearing in degrees true, and degrees magnetic (if available).

SOG is the most recent speed over ground solution, in miles per hour, knots
(nautical miles per hour), and kilometers per hour.

INT is internal Hazer state including the name of the sentence (GLL in the
example above) that most recently updated the solution, the total number of
satellites that contributed to that solution, an indication as to whether the
day-month-year value has been set (only occurs once the RMC sentence has been
received), an indication as to whether time is incrementing monotonically (it
can appear to run backwards when receiving UDP packets because UDP may reorder
them), and some metrics as to the number of significant digits provided for
various datums provided by the device.

ACT is the list of active satellites, typically provided seperately for each
system or constellation by the device, showing each satellites identifying
number (for GPS, this is its pseudo-random noise or PRN code number, but other
systems using other conventions), and the number of satellites in the list.
Unlike the other report lines, the system or constellation to which the data
applies is derived from (in order, depending on availability) the system id
in the GSA sentence (only available on devices that support later NMEA
versions), or an analysis of the satellite identifiers based on NMEA
conventions, or the talker specified at the beginning of the sentence. The
reason for this is that some devices (I'm looking at you, GN803G), specify GNSS
as the talker for all GSA sentences when they are computing an ensemble solution
(one based on multiple constellations); this causes ambiguity between this case
and the case of successive GSA sentences in which the active satellite list has
changed. Hazer independently tries to determine the constellation to which the
GSA sentence refers when the talker is GNSS.

DOP is the position, horizontal, and vertical dilution of precision - measures
of the quality of the position fix (smaller is better) - based on the real-time
geometry of the satellites upon which the current solution is based. If
multiple constellations are reported, but the DOPs are all the same, the device
is typically computing an ensemble solution using multiple constellations.

SAT is the list of satellites in view, including an index that is purely an
artifact of Hazer, the satellites identifying number (same comment as above),
its elevation and azimuth in degrees from its ephemeris, and the signal to
noise ratio (really, a carrier to noise density ratio) in decibels Hertz for
its transmission.

# Notes

N.B. Most of the snapshots below were taken from earlier versions of Hazer and
its gpstool utility. The snapshots were cut and pasted from actual output and
may differ slightly (or greatly) from that of the most current version.

## Sending Commands

gpstool can send initialization commands to the GPS device. These can be either
NMEA sentences (without escape sequences) or binary UBX sentence (with
escape sequences). In either case, gpstool will automatically append the
appropriate ending sequences including a computed NMEA or UBX checksum.
Here is an example of gpstool writing proprietary NMEA and binary UBX sequences
to a NaviSys GR-701W which has a UBlox 7 chipset.

    > gpstool -D /dev/ttyUSB0 -b 9600 -8 -n -1 -c -E \
          -W "\$PUBX,00" \
          -W "\$PUBX,03" \
          -W "\$PUBX,04" \
          -W "\\xB5\\x62\\x06\\x01\\x08\\x00\\x02\\x13\\x00\\x01\\x00\\x00\\x00\\x00" \
          -W "\\xb5\\x62\\x0a\\x04\\x00\\x00" \
          -W "\\xb5\\x62\\x06\\x31\\x00\\x00" \
          -W "\\xb5\\x62\\x06\\x3e\\x00\\x00" \
          -W "\\xb5\\x62\\x06\\x06\\x00\\x00"

(The code to write commands to the device depends on being driven by incoming
data from the device, so if the device is initially silent, this won't work.
All the GPS receivers I've tested are chatty by default, so this hasn't been an
issue for me.)

If a written command is of zero length (really: has a NUL or \0 character as its
first character), gpstool exits. This can be used by a script, for example, to
use gpstool to send a command to change the baud rate of the GPS device serial
port and exit, and then start a new gpstool with the new baud rate.

## Forwarding Datagrams

Here is an example of using gpstool to read an NMEA sentence stream from a
serial device at 115200 8n1, display the data using ANSI escape sequences to
control the output terminal, and forwards NMEA sentences to a remote
instance of itself listing on port 5555 on host "lead".

    > gpstool -D /dev/ttyUSB0 -b 115200 -8 -n -1 -E -6 -A lead -P 5555
    
    $GPRMC,164659.00,A,3947.65335,N,10509.20343,W,0.063,,310718,,,D*63\r\n
    MAP 2018-07-31T16:46:59Z 39*47'39.20"N,105*09'12.20"W  5631.82' N     0.072mph PPS 1
    RMC 39.794222,-105.153391  1716.600m   0.000*    0.063knots [10] 9 10 5 0 4
    GSA {  51   6  12  48  28  19   2  24   3  17 } [10] pdop 1.70 hdop 0.86 vdop 1.47
    GSV [01] sat   2 elv 28 azm 206 snr 40dBHz con GPS
    GSV [02] sat   3 elv 14 azm  59 snr 27dBHz con GPS
    GSV [03] sat   6 elv 67 azm 166 snr 37dBHz con GPS
    GSV [04] sat  12 elv 23 azm 308 snr 33dBHz con GPS
    GSV [05] sat  17 elv 54 azm  44 snr 17dBHz con GPS
    GSV [06] sat  19 elv 72 azm 352 snr 31dBHz con GPS
    GSV [07] sat  22 elv  5 azm  39 snr 21dBHz con GPS
    GSV [08] sat  24 elv 40 azm 287 snr 18dBHz con GPS
    GSV [09] sat  28 elv 30 azm 112 snr 32dBHz con GPS
    GSV [10] sat  46 elv 38 azm 215 snr 34dBHz con GPS
    GSV [11] sat  48 elv 36 azm 220 snr 39dBHz con GPS
    GSV [12] sat  51 elv 44 azm 183 snr 43dBHz con GPS

## Receiving Datagrams

Here is the remote instance of gpstool receiving the NMEA stream via
the UDP socket on port 5555.

    > gpstool -6 -P 5555 -E

    $GPGLL,3947.65274,N,10509.20212,W,164744.00,A,D*7F\r\n
    MAP 2018-07-31T16:47:44Z 39*47'39.16"N,105*09'12.12"W  5612.79' N     0.048mph PPS 0
    GGA 39.794212,-105.153369  1710.800m   0.000*    0.042knots [10] 9 10 5 0 4
    GSA {  51   6  12  48  28  19   2  24   3  17 } [10] pdop 1.71 hdop 0.86 vdop 1.48
    GSV [01] sat   2 elv 28 azm 206 snr 38dBHz con GPS
    GSV [02] sat   3 elv 14 azm  58 snr 26dBHz con GPS
    GSV [03] sat   6 elv 67 azm 165 snr 38dBHz con GPS
    GSV [04] sat  12 elv 24 azm 308 snr 33dBHz con GPS
    GSV [05] sat  17 elv 54 azm  44 snr 21dBHz con GPS
    GSV [06] sat  19 elv 72 azm 353 snr 33dBHz con GPS
    GSV [07] sat  22 elv  5 azm  39 snr 18dBHz con GPS
    GSV [08] sat  24 elv 41 azm 287 snr 19dBHz con GPS
    GSV [09] sat  28 elv 29 azm 112 snr 29dBHz con GPS
    GSV [10] sat  46 elv 38 azm 215 snr 34dBHz con GPS
    GSV [11] sat  48 elv 36 azm 220 snr 39dBHz con GPS
    GSV [12] sat  51 elv 44 azm 183 snr 42dBHz con GPS

## Using screen

You can use the screen utility, available for MacOS and Linux/GNU, to capture
the NMEA stream on a serial port. (And on Windows systems, I use PuTTY.)

    > screen /dev/cu.usbserial-FT8WG16Y 9600 8n1

    $GPRMC,190019.00,A,3947.65139,N,10509.20196,W,0.053,,060818,,,D*66
    $GPVTG,,T,,M,0.053,N,0.099,K,D*20
    $GPGGA,190019.00,3947.65139,N,10509.20196,W,2,10,1.05,1707.9,M,-21.5,M,,0000*5B
    $GPGSA,A,3,06,19,24,51,02,12,48,29,25,05,,,1.75,1.05,1.40*08
    $GPGSV,4,1,14,02,77,008,30,05,42,164,48,06,32,051,20,09,03,060,*71
    $GPGSV,4,2,14,12,73,214,28,17,04,101,13,19,24,092,20,24,06,217,31*71
    $GPGSV,4,3,14,25,45,305,29,29,17,294,11,31,03,327,08,46,38,215,30*71
    $GPGSV,4,4,14,48,36,220,32,51,44,183,42*7C
    $GPGLL,3947.65139,N,10509.20196,W,190019.00,A,D*7E
    $GPRMC,190020.00,A,3947.65143,N,10509.20192,W,0.044,,060818,,,D*63
    $GPVTG,,T,,M,0.044,N,0.081,K,D*2F
    $GPGGA,190020.00,3947.65143,N,10509.20192,W,2,09,1.05,1707.9,M,-21.5,M,,0000*50
    $GPGSA,A,3,06,19,24,51,02,12,48,25,05,,,,1.75,1.05,1.40*03
    $GPGSV,4,1,14,02,77,008,31,05,42,164,48,06,32,051,21,09,03,060,23*70
    $GPGSV,4,2,14,12,73,214,29,17,04,101,12,19,24,092,19,24,06,217,31*7B
    $GPGSV,4,3,14,25,45,305,29,29,17,294,09,31,03,327,06,46,38,215,31*77
    $GPGSV,4,4,14,48,36,220,32,51,44,183,43*7D
    $GPGLL,3947.65143,N,10509.20192,W,190020.00,A,D*7D
    $GPRMC,190021.00,A,3947.65143,N,10509.20191,W,0.050,,060818,,,D*64
    $GPVTG,,T,,M,0.050,N,0.092,K,D*28
    $GPGGA,190021.00,3947.65143,N,10509.20191,W,2,10,1.05,1708.0,M,-21.5,M,,0000*5C

## Using gpsd

You can test GPS devices independently of this software using the
excellent Linux open source GPS stack. Here is just a simple example of
stopping the GPS daemon if it has already been started (make sure you
are not going to break something doing this), restarting it in non-deamon
debug mode, and running a client against it. In this example, I use the
Garmin GLO Bluetooth device I have already set up, and the X11 GPS client.
When I'm done, I restart gpsd in normal daemon mode.

    > sudo service gpsd stop
    > gpsd -N /dev/rfcomm0 &
    > xgps
    ...
    > kill %+
    > sudo service start gpsd

## Using socat

You can use the socat utility, available for Linux/GNU and MacOS flavored
systems, to capture the NMEA stream on the UDP port.

    > socat UDP6-RECVFROM:5555,reuseaddr,fork STDOUT

    $GPGSA,M,3,32,10,14,18,31,11,24,08,21,27,01,,1.3,0.8,1.1*33
    $GPGSV,3,1,12,32,79,305,39,10,66,062,41,14,58,247,35,18,40,095,34*72
    $GPGSV,3,2,12,31,21,180,45,11,20,309,27,24,19,044,30,08,17,271,31*7A
    $GPGSV,3,3,12,21,13,156,39,27,13,233,33,01,09,320,20,51,43,183,42*72

You may be tempted (I was) to dispense with gpstool entirely and use
socat to forward NMEA strings to a remote site.  Be aware that when
used in UDP consumer mode, gpstool expects every UDP datagram to be
a fully formed NMEA sentence, because that's how it sends them in UDP
producer mode. socat isn't so polite. Since the occasional UDP packet
will inevitably be lost, if the output of socat is piped into gpstool,
it will see a lot of corruption in the input stream. Using gpstool on
both ends means only entire NMEA sentences are lost, and gpstool can
recover from this.

    > socat OPEN:/dev/ttyUSB0,b115200 UDP6-SENDTO:[::1]:5555

The RMC and GGA sentences contain UTC timestamps (and the RMC contains
a DMY datestamp). Hazer rejects sentences for which time runs backwards.
Although this should be impossible for the sentences in the stream from
a GPS device, it is entirely possible for the UDP stream from a Hazer
producer, since UDP packet ordering is not guaranteed.

You might be tempted to use TCP instead of UDP. That sounds like a good
idea: guaranteed delivery, packets always in order. However, this can
introduce a lot of lantency in the NMEA stream. The result is the NMEA
stream received by the consumer may lag signficantly behind real-time,
and that lag increases the longer the system runs. So over time it
diverges more and more with reality.  It is better to lose an NMEA
sentence than have it delayed. After all, another more up-to-date sentence
is on the way right behind it.

## Using Bluetooth

You can use gpstool with Bluetooth GPS units like the Garmin GLO.

    > sudo bluetoothctl
    power on
    agent on
    scan on
    ...
    scan off
    pair 01:23:45:67:89:AB
    quit
    > sudo rfcomm bind 0 01:23:45:67:89:AB 1
    > sudo chmod 666 /dev/rfcomm0
    > gpstool -D /dev/rfcomm0 -E

    $GPVTG,350.4,T,341.6,M,000.08,N,0000.15,K,D*18\r\n
    MAP 2017-09-14T14:22:05Z 39*47'39.20"N,105*09'12.13"W  5613.45' N     0.092mph
    GGA 39.794223,-105.153371  1711.000m 350.400*    0.080knots [12] 10 11 5 4 5
    GSA {  30  28  84   2  19   6  91  24  12  22  72   3 } [12] pdop 1.20 hdop 0.70 vdop 1.00
    GSV [01] sat  51 elv 43 azm 182 snr 45dBHz con GPS
    GSV [02] sat  30 elv  4 azm 161 snr 31dBHz con GPS
    GSV [03] sat  28 elv 35 azm 105 snr 22dBHz con GPS
    GSV [04] sat  84 elv 45 azm 245 snr 37dBHz con GPS
    GSV [05] sat   2 elv 21 azm 204 snr 36dBHz con GPS
    GSV [06] sat  19 elv 74 azm 346 snr 42dBHz con GPS
    GSV [07] sat   6 elv 56 azm 175 snr 45dBHz con GPS
    GSV [08] sat  91 elv 66 azm   5 snr 25dBHz con GPS
    GSV [09] sat  24 elv 36 azm 301 snr 26dBHz con GPS
    GSV [10] sat  12 elv 13 azm 304 snr 32dBHz con GPS
    GSV [11] sat  22 elv  7 azm  46 snr 24dBHz con GPS
    GSV [12] sat  72 elv 39 azm 326 snr 30dBHz con GPS
    GSV [13] sat   3 elv 14 azm  67 snr 27dBHz con GPS

    > sudo rfcomm release 0
    > sudo bluetoothctl
    power off
    quit

## Using One Pulse Per Second

Some GPS devices provide a 1Hz One Pulse Per Second (1PPS) signal that is, if
implemented correctly, closely phase locked to GPS time. Hazer and its
gpstool utility are user-space software running on a non-real-time operating
system, so any periodic action by Hazer is at best approximate in terms of
period. But handling 1PPS even with some jitter is useful for casual testing
of GPS devices.

You can test GPS devices like the NaviSys GR-701W that provide 1PPS by toggling
the Data Carrier Detect (DCD) modem control line. This includes devices that
have a USB serial interface. Note the addition of the -c flag.

    > gpstool -D /dev/ttyUSB0 -b 9600 -8 -n -1 -E -c
    
    $GPRMC,174227.00,A,3947.65321,N,10509.20367,W,0.027,,040518,,,D*68\r\n
    MAP 2018-05-04T17:42:27Z 39*47'39.19"N,105*09'12.22"W  5600.00' N     0.031mph 1PPS
    RMC 39.794220,-105.153395  1706.900m   0.000*    0.027knots [10] 9 10 5 0 4
    GSA {   9   7   8  30  51  27  23  48  28  11 } [10] pdop 2.13 hdop 1.01 vdop 1.88
    GSV [01] sat   5 elv 10 azm 297 snr 22dBHz con GPS
    GSV [02] sat   7 elv 72 azm 348 snr 31dBHz con GPS
    GSV [03] sat   8 elv 56 azm  92 snr 23dBHz con GPS
    GSV [04] sat   9 elv 52 azm 187 snr 36dBHz con GPS
    GSV [05] sat  11 elv 18 azm 143 snr 34dBHz con GPS
    GSV [06] sat  16 elv  1 azm  55 snr  0dBHz con GPS
    GSV [07] sat  18 elv  4 azm 125 snr 27dBHz con GPS
    GSV [08] sat  23 elv 18 azm 161 snr 43dBHz con GPS
    GSV [09] sat  27 elv 29 azm  48 snr 31dBHz con GPS
    GSV [10] sat  28 elv 35 azm 246 snr 32dBHz con GPS
    GSV [11] sat  30 elv 48 azm 307 snr 35dBHz con GPS
    GSV [12] sat  46 elv 38 azm 215 snr 43dBHz con GPS
    GSV [13] sat  48 elv 36 azm 220 snr 42dBHz con GPS
    GSV [14] sat  51 elv 44 azm 183 snr 37dBHz con GPS

You can also test GPS devices like the MakerFocus USB-Port-GPS that provide
1PPS by toggling a General Purpose I/O (GPIO) pin. This example (which I've run
on a Raspberry Pi) uses pin 18. Note the addition of the -I flag. (You may have
to run gpstool as root to access the GPIO pins.)

    # gpstool -D /dev/ttyUSB1 -b 9600 -8 -n -1 -I 18 -E
    
    $GPGSV,3,1,11,23,85,357,39,16,62,069,40,09,45,311,37,51,43,183,43*75\r\n
    MAP 2018-05-08T14:50:25Z 39*47'39.17"N,105*09'12.19"W  5588.51' N     0.000mph
    GGA 39.794215,-105.153387  1703.400m   0.000*    0.000knots [09] 8 9 5 3 3
    GSA {   8   7  22  26  23   9   3  16  27 } [09] pdop 1.94 hdop 1.03 vdop 1.64
    GSV [01] sat  23 elv 85 azm 357 snr 39dBHz con GPS
    GSV [02] sat  16 elv 62 azm  69 snr 40dBHz con GPS
    GSV [03] sat   9 elv 45 azm 311 snr 37dBHz con GPS
    GSV [04] sat  51 elv 43 azm 183 snr 44dBHz con GPS
    GSV [05] sat  26 elv 34 azm  48 snr 28dBHz con GPS
    GSV [06] sat   3 elv 33 azm 200 snr 44dBHz con GPS
    GSV [07] sat   7 elv 23 azm 268 snr 28dBHz con GPS
    GSV [08] sat  27 elv 20 azm 126 snr 36dBHz con GPS
    GSV [09] sat  22 elv 16 azm 183 snr 42dBHz con GPS
    GSV [10] sat   8 elv  5 azm 160 snr 34dBHz con GPS
    GSV [11] sat  31 elv  2 azm  73 snr  0dBHz con GPS

gpstool can assert an output GPIO pin in approximate syntonization with the
1PPS signal derived from either DCD or GPIO. This example (which I've run on a
Raspberry Pi with the GR-701W) uses pin 16. Note the addition of the -p flag.
(Again, you may have to run gpstool as root to access the GPIO pins.)

    # gpstool -D /dev/ttyUSB0 -b 9600 -8 -n -1 -E -c -p 16

The GPIO functions implemented in Diminuto and used by gpstool may get confused
if gpstool exits ungracefully leaving GPIO pins configured. If necessary, you
can deconfigure GPIO pins using the Diminuto pintool utility

    # pintool -p 18 -n
    # pintool -p 16 -n

## True Versus Magnetic Bearings

GPS devices compute the true bearing by comparing successive position fixes to
determine your speed and direction. Hence, the true bearing, e.g. "135.000\*T",
is only reliable if you are moving, and at a speed fast enough to be within
the resolution of the accuracy of the position fix. The magnetic bearing is an
actual magnetic compass bearing, but is only provided by GPS devices which also
have a magnetic compass; otherwise it will be displayed as "0.000\*M". The
cardinal compass direction, e.g. "SE", is based on the true bearing.

## Google Earth Pro

In February 2017 I used Hazer with Google Earth Pro, the desktop version of the
web based application. Today, August 2018, the real-time GPS feature of Google
Earth Pro no longer seems to work with latest version, 7.3.2, for the Mac (I
haven't tried it for other operating systems). Neither does 7.3.1. But 7.1.8
works.

Google Earth Pro only accepts GPS data on a serial port, or at least somethin
that kinda sorta looks like a serial port. So I process the NMEA stream from a
serial-attached GPS device using gpstool running on a Linux server, then
forwarded it via UDP datagrams to another gpstool on the same server, and then
use that gpstool to forward the NMEA stream out a serial port across a two FTDI
USB-to-serial adaptors hooked back-to-back with a null modem in between, to a
Mac running Google Earth Pro.

Empirically and anecdotally, but undocumentedly, Google Earth Pro appears to
only accept serial input at 4800 baud. More recent and advanced GPS devices
default to 9600 baud, and can overrun a 4800 baud serial port. So I used a
USGlobalSat BU-353S4, which defaults to 4800 baud, as my GPS device on the
Linux server.

As Rube Goldberg as this is, it seems to work.

## NMEA TXT Sentences

Some devices are chatty and emit interesting and sometimes useful information
as NMEA TXT sentences. These can be recognized by Hazer and logged to standard
error by gpstool. Some of the functional tests save standard error output in
log files under the build artifact directory.

    gpstool: TEXT [01][01][02] "u-blox AG - www.u-blox.com"
    gpstool: TEXT [01][01][02] "HW UBX-M8030 00080000"
    gpstool: TEXT [01][01][02] "ROM CORE 3.01 (107888)"
    gpstool: TEXT [01][01][02] "FWVER=SPG 3.01"
    gpstool: TEXT [01][01][02] "PROTVER=18.00"
    gpstool: TEXT [01][01][02] "GPS;GLO;GAL;BDS"
    gpstool: TEXT [01][01][02] "SBAS;IMES;QZSS"
    gpstool: TEXT [01][01][02] "GNSS OTP=GPS;GLO"
    gpstool: TEXT [01][01][02] "LLC=FFFFFFFF-FFFFFFFF-FFFFFFFF-FFFFFFFF-FFFFFFFD"
    gpstool: TEXT [01][01][02] "ANTSUPERV=AC SD PDoS SR"
    gpstool: TEXT [01][01][02] "ANTSTATUS=OK"
    gpstool: TEXT [01][01][02] "PF=3FF"

# Acknowledgements

Special thanks to Mrs. Overclock for her assistance in road testing this
software.

