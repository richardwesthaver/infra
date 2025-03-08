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
cp -a libbz2.so* /usr/local/lib/
# for fedora...
ln -sf /usr/local/lib/libbz2.so libbz2.so.1.0 
cp -rf bzlib.h /usr/local/include/
