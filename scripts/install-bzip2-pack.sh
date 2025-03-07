#!/bin/sh
set -e
cd .stash/tmp
if [ ! -d "bzip2" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  pack="${PACKY_HOME}/dist/${TARGET}/bzip2.tar.zst"
  case $PACKY_URL in
    "http"*) curl -O $pack ;;
    *) cp $pack ./ ;;
  esac
  unzstd bzip2.tar.zst
  tar -xvf bzip2.tar
fi
cd bzip2
cp libbzip2.so* /usr/lib/
cp -rf bzlib.h /usr/include/
