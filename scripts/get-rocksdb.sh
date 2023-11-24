#!/usr/bin/bash
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/rocksdb-$VER)}
DISTDIR=${3:-$(realpath dist)}
mkdir -pv dist/include
git clone https://vc.compiler.company/packy/shed/vendor/rocksdb.git $TARGETDIR
pushd $TARGETDIR
make shared_lib DISABLE_JEMALLOC=1 && 
cp -r librocksdb.so include/* $DISTDIR
popd
