#!/bin/sh
set -e
cd .stash/tmp
if [ ! -d "liburing" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  pack="${PACKY_HOME}/dist/${TARGET}/liburing.tar.zst"
  case $PACKY_URL in
    "http"*) curl -O "$pack" ;;
    *) cp "$pack" ./ ;;
  esac
  unzstd liburing.tar.zst
  tar -xvf liburing.tar
fi
cd liburing
cp liburing*.so* /usr/lib/
cp -arf include/* /usr/include/
