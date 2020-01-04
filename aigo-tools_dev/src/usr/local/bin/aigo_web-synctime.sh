#!/bin/bash

TIMESTAMP=$1
# +1 sec = browser php exec shell delay
SHIFTTIME=$(($TIMESTAMP+1))
DATETIME=`date -d "1970-01-01 UTC "$SHIFTTIME" seconds"`

date --set="$DATETIME"
