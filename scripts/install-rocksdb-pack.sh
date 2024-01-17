#!/bin/sh
# the rocksdb pack only includes the shared library and headers. the
# static library is shipped separately.
set -e
cd build/src
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/rocksdb-binary.tar.zst
unzstd rocksdb-binary.tar.zst
tar -xvf rocksdb-binary.tar
cd rocksdb
cp librocksdb.* /usr/local/lib/
cp -rf include/* /usr/local/include/
