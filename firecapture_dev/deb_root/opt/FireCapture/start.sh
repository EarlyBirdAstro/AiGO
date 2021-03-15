#!/bin/bash
#
# FireCapture Startup script 

heap="$(cat FireCapture.ini | grep heapsize | cut -d'=' -f2)"

if [ -z "$heap" ]
then
#      heap=1024
##      heap=2048
      heap=256
#      heap=3096
fi

if [ ! -e jre/lib/rt.jar ] 
then
    echo "extracting library - please wait..."
    jre/bin/unpack200 -J-Xmx256m jre/lib/rt.jar.gz jre/lib/rt.jar
fi

if [ -d update ]; then
   cp update/*.jar lib
   cp update/*.so .
   cp update/*.dylib .
   rm -rf update
fi

cp=$(find lib -name "*.jar" -exec printf :{} ';')
if [[ -n "$CLASSPATH" ]]; then
    cp="$cp;CLASSPATH"
fi

#./jre/bin/FireCapture -Xms${heap}m -Xmx${heap}m -XX:+UseCompressedOops  -classpath "$cp" de.wonderplanets.firecapture.gui.FireCapture
./jre/bin/java -Xms${heap}m -Xmx${heap}m -classpath "$cp" de.wonderplanets.firecapture.gui.FireCapture

#read -n 1 -s -r -p "Press any key to continue"

