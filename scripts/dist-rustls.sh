#!/bin/sh
cd .stash
mkdir rustls
cp src/rustls-ffi/librustls.so src/rustls-ffi/librustls/src/rustls.h rustls/
tar -I 'zstd' -cf rustls.tar.zst rustls
rm -rf rustls

