#!/bin/sh
set -e
cd .stash
mkdir liburing
cp -raf src/liburing/src/liburing*.so* src/liburing/src/include liburing/
cd liburing
ln -sf "$(echo liburing.so.*.*)" liburing.so
ln -sf "$(echo liburing-ffi.so.*.*)" liburing-ffi.so
cd ..
tar -I 'zstd' -cf liburing.tar.zst liburing 
rm -rf liburing
