#!/usr/bin/bash
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/rocksdb-$VER)}
DISTDIR=${3:-$(realpath dist)}
git clone https://vc.compiler.company/packy/shed/vendor/rocksdb.git $TARGETDIR
pushd $TARGETDIR
make shared_lib DISABLE_JEMALLOC=1 && 
mkdir -pv $DISTDIR/include
mkdir -pv $DISTDIR/lib
# cp -rf include/* $DISTDIR
# cp -f librocksdb.so* $DISTDIR/lib/
popd
