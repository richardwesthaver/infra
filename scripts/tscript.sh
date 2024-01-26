#!/bin/sh
# make typescript of terminal session. this will generate two files:
# the raw terminal data and a timing log file. 
set -e
name="${1:-ts-$(date +%s)}"
log="${2:-$name.log}"
script --t="$log" -q "$name" ${3:+-c $3}

