#!/bin/bash
# Get GPU stats using nvidia-smi
# Usage, Temp, VRAM Used, VRAM Total
info=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits)

# Parse values
usage=$(echo $info | cut -d',' -f1 | tr -d ' ')
temp=$(echo $info | cut -d',' -f2 | tr -d ' ')
mem_used=$(echo $info | cut -d',' -f3 | tr -d ' ')
mem_total=$(echo $info | cut -d',' -f4 | tr -d ' ')

# Calculate VRAM percentage
mem_perc=$(( 100 * mem_used / mem_total ))

# Output JSON for Waybar
echo "{\"text\":\"󰢮   $usage% / $temp°C / $mem_used MB\", \"tooltip\":\"GPU Usage: $usage%\nTemp: $temp°C\nVRAM: $mem_used / $mem_total MB ($mem_perc%)\"}"
