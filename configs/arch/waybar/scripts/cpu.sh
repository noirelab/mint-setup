#!/bin/bash

# 1. Get CPU Usage - Using /proc/stat (more accurate and locale-independent)
cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%d", usage}')

# 2. Get CPU Temperature
cpu_temp=$(sensors | grep "Package id 0" | awk '{print $4}' | tr -d '+°C' | cut -d. -f1 | cut -d, -f1)

if [ -z "$cpu_temp" ]; then
    cpu_temp=$(sensors | grep "Core 0" | awk '{print $3}' | tr -d '+°C' | cut -d. -f1 | cut -d, -f1)
fi

# 3. Get CPU Frequency - Using /proc/cpuinfo for better reliability
# We take the average frequency of all cores and convert to GHz
cpu_freq=$(awk '/cpu MHz/ {sum+=$4; count++} END {printf "%.1f", sum/count/1000}' /proc/cpuinfo | tr ',' '.')

# Output JSON for Waybar
echo "{\"text\":\"󰘚  $cpu_usage% / $cpu_temp°C / $cpu_freq GHz\", \"tooltip\":\"CPU Usage: $cpu_usage%\nTemp: $cpu_temp°C\nFreq: $cpu_freq GHz\"}"
