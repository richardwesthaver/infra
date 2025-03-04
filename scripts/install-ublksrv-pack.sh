#!/bin/sh
set -e
cd .stash/tmp
if [ ! -d "ublksrv" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  pack="${PACKY_HOME}/dist/${TARGET}/ublksrv.tar.zst"
  case $PACKY_URL in
    "http"*) curl -O $pack ;;
    *) cp $pack ./ ;;
  esac
  unzstd ublksrv.tar.zst
  tar -xvf ublksrv.tar
fi
cd ublksrv
cp libublksrv.so* /usr/local/lib/
cp include/* /usr/local/include/
