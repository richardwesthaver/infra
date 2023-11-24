#!/usr/bin/bash
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/rocksdb-$VER)}
git clone https://vc.compiler.company/packy/shed/vendor/rocksdb.git $TARGETDIR
pushd $TARGETDIR
make shared_lib
sudo make install
popd
