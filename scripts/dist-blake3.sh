#!/bin/sh
set -e
cd .stash 
mkdir blake3 
cp src/blake3/c/libblake3.so src/blake3/c/blake3.h blake3/ 
tar -I 'zstd' -cf blake3.tar.zst blake3 
rm -rf blake3

