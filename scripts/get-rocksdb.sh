#!/usr/bin/bash
# get RocksDB source code
TARGETDIR=${2:-$(realpath build/src/rocksdb)}
git clone https://vc.compiler.company/packy/shed/vendor/rocksdb.git $TARGETDIR
