#!/bin/sh
# the rocksdb pack only includes the shared library and headers. the
# static library is shipped separately.
set -e
cd build/src
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/rocksdb.tar.zst
unzstd rocksdb.tar.zst
tar -xvf rocksdb.tar
cd rocksdb
cp librocksdb.* /usr/local/lib/
cp -rf include/* /usr/local/include/
