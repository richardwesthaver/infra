#!/bin/sh
set -e
cd .stash/src
tar -cf rocksdb.tar.zst rocksdb/librocksdb.so* rocksdb/include/*
zstd rocksdb.tar
rm rocksdb.tar
mv rocksdb.tar.zst ../
