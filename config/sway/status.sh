#!/bin/bash

IFACE=$(ip route | awk '/default/ {print $5}' | head -n1)

RX_PREV=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
TX_PREV=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)

while true; do
sleep 1

RX_NOW=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
TX_NOW=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)

RX_RATE=$((RX_NOW - RX_PREV))
TX_RATE=$((TX_NOW - TX_PREV))

RX_PREV=$RX_NOW
TX_PREV=$TX_NOW

RX_KB=$((RX_RATE / 1024))
TX_KB=$((TX_RATE / 1024))

TITLE=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .name')

CPU=$(grep 'cpu ' /proc/stat | awk '{u=$2+$4; t=$2+$4+$5} END {print int(u*100/t)}')
RAM=$(free | awk '/Mem/ {printf("%.0f", $3/$2 * 100)}')

VOLINFO=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

if echo "$VOLINFO" | grep -q MUTED; then
VOL="MUTE"
else
VOL=$(echo "$VOLINFO" | awk '{printf("%d%%",$2*100)}')
fi

DATE=$(date "+%d/%m/%y %H:%M")

WIDTH=$(tput cols)

LEFT="$TITLE"
RIGHT="CPU ${CPU}% | RAM ${RAM}% | VOL ${VOL} | NET ↓${RX_KB}K ↑${TX_KB}K | ${DATE}"

printf "%-*s%s\n" $((WIDTH-${#RIGHT})) "$LEFT" "$RIGHT"

done
