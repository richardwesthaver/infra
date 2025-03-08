#!/bin/sh
set -e
cd .stash/tmp
if [ ! -d "zstd" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  pack="${PACKY_HOME}/dist/${TARGET}/zstd.tar.zst"
  case $PACKY_URL in
    "http"*) curl -O $pack ;;
    *) cp $pack ./ ;;
  esac
  unzstd zstd.tar.zst
  tar -xvf zstd.tar
fi
cd zstd
cp -a libzstd.so* /usr/local/lib/
cp *.h /usr/local/include/
