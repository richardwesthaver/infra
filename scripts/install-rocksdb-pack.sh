#!/usr/bin/env bash
cd build/src 
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/rocksdb-binary.tar.zst
unzstd rocksdb-binary.tar.zst | tar xvf -
cd rocksdb
sh install.sh
