#!/bin/sh
# the rocksdb pack only includes the shared library and headers. the
# static library is shipped separately.
set -e
cd .stash/cache/tmp
if [ ! -d "rocksdb" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  pack="${PACKY_HOME}/dist/${TARGET}/rocksdb.tar.zst"
  case $PACKY_URL in
    "http"*) curl -O $pack ;;
    *) cp $pack ./ ;;
  esac
  unzstd rocksdb.tar.zst
  tar -xvf rocksdb.tar
fi
cd rocksdb
cp librocksdb.* /usr/lib/
cp -rf include/* /usr/include/
