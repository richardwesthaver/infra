#!/usr/bin/bash
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/lust-$VER)}
hg clone https://vc.compiler.company/lust $TARGETDIR
pushd $TARGETDIR
make
sudo make install
popd
