#!/usr/bin/bash
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/src/rocksdb-$VER)}
git clone https://vc.compiler.company/packy/shed/vendor/rocksdb.git $TARGETDIR
