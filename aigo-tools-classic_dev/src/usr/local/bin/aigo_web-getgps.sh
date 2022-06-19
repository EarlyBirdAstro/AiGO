#!/bin/bash

LON=$1
LAT=$2
ALT=$3
TS=$4
TZ=`date +%:::z`

GPSFILE=/home/aigo/gps.txt
echo "lon="$LON > $GPSFILE
echo "lat="$LAT >> $GPSFILE
echo "alt="$ALT >> $GPSFILE
echo "tm="$TS   >> $GPSFILE
echo "tz="$TZ   >> $GPSFILE

chown aigo.aigo $GPSFILE
chmod 644 $GPSFILE
