#!/usr/bin/env bash
# get RocksDB source code
TARGETDIR=${2:-build/src/rocksdb}
git clone https://vc.compiler.company/packy/shed/vendor/rocksdb.git $TARGETDIR
