#!/bin/sh
set -e
cd .stash
mkdir bzip2
cp -raf src/bzip2/build/libbz2.so* src/bzip2/bzlib.h bzip2/
cd bzip2
rm -rf libbz2.so*.p
ln -sf "$(echo libbz2.so.1.*.*)" libbz2.so.1.0
cd ..
tar -I 'zstd' -cf bzip2.tar.zst bzip2 
rm -rf bzip2
