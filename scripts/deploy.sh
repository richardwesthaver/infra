#!/bin/sh
if [ -n "${DESTINATION}" ]; then DESTINATION="/mnt/y/data/packy"; fi
shift
for var in "$@"
do
  if [ -e "$var" ]; then
    cp -rf "$var" "$DESTINATION"
  else 
    echo "input is missing: $var"
  fi
done
