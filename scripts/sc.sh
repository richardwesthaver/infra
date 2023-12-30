#!/bin/sh
# take screenshot of current window on sway
swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | grim -g - ${1:-"$(date +%s).png"}
