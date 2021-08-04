# Issues

Here is a list of weird things I've observed in my travels using
various GNSS modules. U-blox may appear to be over represented
here, but that's only because they're my favorite GNSS device
manufacturer.

## Wrong number of satellites reported for GLONASS on U-Blox UBX-ZED-F9P

The Ardusimple SimpleRTK2B board uses the U-Blox ZED-F9P GPS receiver.
I'm pretty sure the firmware in the ZED-F9P-00B-01 chip on my SimpleRTK2B
board has a bug. I believe this GSV sentence that it emitted is incorrect.

    $GLGSV,3,3,11,85,26,103,25,86,02,152,29,1*75\r\n

This GSV sentence says it is the third of three GSV sentences for the
GLONASS constellation, and there are eleven total satellites cited in
the three GSV sentences.

GSV is unusual amongst the typical NMEA sentences in that it is variable
length. Each GSV sentence can contain at most four satellites, each
represented by four numbers: the space vehicle ID (which is specific to
the constellation), the SV's elevation in degrees, the SV's azimuth in
degrees, and the signal strength in dB Hz.

The two prior GSV sentences for this report of GLONASS satellites in
view would have had at most four satellites, for a total of eight,
leaving three satellites for this final sentence in the sequence. This
sentence only has the metrics for two satellites. Note also that this
messages has the optional signal identifier as its last field before
the checksum.

I think either there should be a third set of four fields for the eleventh
satellite, or the total count should be ten instead of eleven. My software
has been modified to account for this malformed message; it originally
core dumped with a segmentation violation.

(2019-06-06: U-Blox says this FW bug will be fixed in a subsequent release.)

## Lost Characters on Gen 8 and Gen 9 U-blox Modules using USB ACM Port

I've been troubleshooting a weird issue with sequences of characters being
lost on the modem-ish (ttyACM) USB connection on a U-blox UBX-ZED-F9P
(generation 9) chip. This occurs when using the Ardusimple SimpleRTK2B and
Sparkfun GPS-RTK2 boards. I also see it a U-Blox UBX-M8030 (generation 8)
chip in a GlobalSat BU353W10 dongle. I've seen in on Intel (Dell) and
ARM (Raspberry Pi 3B+ and 4B) systems. I've seen it using my software,
using socat, and even just using cat, to collect data off the USB port.
I've seen it at a variety of baud rates, and whether I had modem control
enabled on the port or not. I've used the Linux usbmon USB debugging tool
to establish that the characters are missing at a very low level in the
USB driver. And finally I used a Total Phase USB Protocol Analyzer
hardware tool to verify that the characters are already missing as
the data comes out of the GPS module, before it ever reaches my Linux
system. Although this insures that the data isn't being dropped by my
software or my hardware, my hardware and the underlying USB hardware
and OS drivers likely have something to do with it: I see it occur much
more often on the Intel servers, and on those, more often on the faster
processors.

I've described this at length in the article

<https://coverclock.blogspot.com/2019/06/this-is-what-you-have-to-deal-with.html>

The u-blox support forum is full of people reporting this same thing.

## End Of File (EOF) on U-blox UBX-ZED-F9P when using Ubuntu VM

Several times, while running this software under Ubunto 19.10 in a
virtual machine on a Lenovo ThinkPad T430s running Windows 10 using a
U-blox ZED-F9P receiver on a SparkFun GPS-RTK2 board - and only under
those circumstances - I've seen gpstool receive an EOF from the input
stream. The standard I/O function ferror() returned false and feof()
returned true (so the underlying standard I/O library thinks it was a
real EOF - which in this context I think means a disconnect - and not
an error). The tool fired right back up with no problem. This happens
very infrequently, and my suspicion is that VMware Workstation 15 Pro is
disconnecting the USB interface from the VM for some reason, maybe as a
result of Windows 10 power management on the laptop. This is something
to especially worry about if you are running a long term survey which
would be interrupted by this event. (I was doing this mostly to test
VMware and my Ubuntu installation on my field laptop.)

## Corruption of Serial Data Stream by LTE-M RF on U-blox UBX-CAM-M8Q

For my Wheatstone project, I used a Digi XBee LTE-M radio in "transparent
mode" to send JSON datagrams via UDP based on output from gpstool.
My initial test setup had me reading the serial port of a U-Blox CAM-M8Q
GNSS receiver using an FTDI-to-serial convertor. It ran flawlessly for
days.

In my second test setup, I was running gpstool on a Raspberry Pi and
reading the output stream of the CAM-M8Q via the RPi's serial port. I
used typical jumper wires to go from the CAM-M8Q (really, from the pins
on the Digi XBIB-CU-TH development board that were connected to the
CAM-M8Q on the Digi XBIB-C-GPS daughter board) to the RPi.

This worked initially. But a couple of days later I started getting
garbage characters - typically with a lot of bits set, like 0xf4 - in the
middle of NMEA sentences, causing gpstool to reject the sentence (checksum
failure) and resync with the stream. Eventually I could only run a test
for a few minutes; the NMEA stream would desync and then fail to resync.
If I restarted gpstool, it would run okay for a few minutes, then fail in
the same way.

It took me most of a morning to debug this. It turned out the jumper wires
for the serial connection, which were unshielded and not twisted pair, had
gotten right up against the cellular antenna for the LTE-M radio as I had
moved stuff around on my lab bench. The transmit RF power was apparently
enough to induce a signal on the serial connection, which could only
occasionally be decoded by the UART in the RPi as a valid (but incorrrect)
data frame.

I switched to a different cellular antenna, rearranged my lab bench,
and my test has run flawlessly for many hours since then.