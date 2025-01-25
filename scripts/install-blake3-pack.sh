#!/bin/sh
set -e
cd .stash/tmp
if [ ! -d "blake3" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  VERSION="${2:-31.0.50}"
  pack="${PACKY_URL}/dist/${TARGET}/blake3.tar.zst"
  if [[ "$PACKY_URL" =~ ^https?://([^/]+) ]]; then
    curl -O $pack
  else
    cp $pack ./
  fi
  unzstd blake3.tar.zst
  tar -xvf blake3.tar
fi
cd blake3
cp libblake3.so /usr/local/lib/
cp blake3.h /usr/local/include/
