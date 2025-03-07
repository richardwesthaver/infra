#!/bin/sh
cd .stash 
mkdir bzip2
cp -rf src/bzip2/build/libbz2.so* src/bzip2/bzlib.h bzip2/
rm -rf bzip2/libbz2.so*.p
tar -I 'zstd' -cf bzip2.tar.zst bzip2 
rm -rf bzip2
