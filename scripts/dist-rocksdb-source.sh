#!/bin/sh
set -e
cd .stash/src/rocksdb
make clean
cd ..
tar -I 'zstd' -cf rocksdb-source.tar.zst rocksdb
mv rocksdb-source.tar.zst ../
