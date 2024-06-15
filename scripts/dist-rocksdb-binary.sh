#!/bin/sh
set -e
cd .stash/src
tar -I 'zstd' -cf rocksdb.tar.zst rocksdb/librocksdb.so* rocksdb/include/*
mv rocksdb.tar.zst ../dist/
