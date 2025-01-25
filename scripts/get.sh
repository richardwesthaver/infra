#!/bin/sh
if [[ "$1" =~ ^https?://([^/]+) ]]; then
  curl -O $pack
else
  cp $pack ./
fi
