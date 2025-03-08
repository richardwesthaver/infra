#!/bin/sh
set -e
cd .stash
mkdir zstd
cp -rf src/zstd/lib/libzstd.so.*.*.* src/zstd/lib/zstd.h src/zstd/lib/zdict.h src/zstd/lib/zstd_errors.h zstd/
cd zstd
ln -sf "$(echo libzstd.so.?.?.?)" libzstd.so
cd ..
tar -I 'zstd' -cf zstd.tar.zst zstd
rm -rf zstd
