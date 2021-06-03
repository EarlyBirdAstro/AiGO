#!/bin/bash

cpuTemp0=$(cat /sys/class/thermal/thermal_zone0/temp)
cpuTemp1=$(($cpuTemp0/1000))
cpuTemp2=$(($cpuTemp0/100))
cpuTempM=$(($cpuTemp2 % $cpuTemp1))
cpuFreq=$(sudo cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq)
cpuFreqM=$(($cpuFreq/1000))
echo CPU current frequency"="$cpuFreqM" MHz"
echo CPU temp"="$cpuTemp1"."$cpuTempM"'C"
echo GPU $(vcgencmd measure_temp)
echo Core $(vcgencmd measure_volts core)
echo SDRAM $(vcgencmd measure_volts sdram_c)
