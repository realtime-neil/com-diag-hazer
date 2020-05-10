#!/bin/bash
# Copyright 2020 Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in LICENSE.txt
# Chip Overclock <coverclock@diag.com>
# https://github.com/coverclock/com-diag-hazer
# Filter that reads CSV and outputs KML XML.
# Based on output from GPS Visualizer <https://www.gpsvisualizer.com>.
# Reference: "OGC KML 2.3", 2015 <http://docs.opengeospatial.org/is/12-007r2/12-007r2.html>

echo    '<?xml version="1.0" encoding="utf-8" standalone="yes"?>'
echo    '<kml xmlns="http://www.opengis.net/kml/2.2">'
echo    '  <Document>'
echo    '    <name><![CDATA[Tumbleweed]]></name>'
echo    '    <visibility>1</visibility>'
echo    '    <open>1</open>'
echo    '    <Snippet><![CDATA[See <a href="https://github.com/coverclock/com-diag-hazer/Hazer/bin/csv2kml.sh">csv2kml</a>]]></Snippet>'
echo    '    <Folder id="Tracks">'
echo    '      <name>Tracks</name>'
echo    '      <visibility>1</visibility>'
echo    '      <open>0</open>'
echo    '      <Placemark>'
echo    '        <name><![CDATA[benchmark]]></name>'
echo    '        <Snippet></Snippet>'
echo    '        <description><![CDATA[&nbsp;]]></description>'
echo    '        <Style>'
echo    '          <LineStyle>'
echo    '            <color>ff0000e6</color>'
echo    '            <width>4</width>'
echo    '          </LineStyle>'
echo    '        </Style>'
echo    '        <LineString>'
echo    '          <tessellate>1</tessellate>'
echo    '          <altitudeMode>clampToGround</altitudeMode>'
echo -n '          <coordinates>'

while read NAM NUM CLK TIM LAT LON HOR MSL WGS VER SOG COG; do

	if [[ "${NUM}" == "OBSERVATION," ]]; then
		continue
	fi

	LATITUDE=${LAT%,}
	LONGITUDE=${LON%,}
	ALTITUDE=${MSL%,}

	echo -n "${LONGITUDE},${LATITUDE},${ALTITUDE} "

done

echo              '</coordinates>'
echo    '        </LineString>'
echo    '      </Placemark>'
echo    '    </Folder>'
echo    '  </Document>'
echo    '</kml>'

exit 0
