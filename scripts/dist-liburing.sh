#!/bin/sh
cd .stash 
mkdir liburing
cp -rf src/liburing/src/liburing*.so* src/liburing/src/include liburing/
tar -I 'zstd' -cf liburing.tar.zst liburing 
rm -rf liburing
