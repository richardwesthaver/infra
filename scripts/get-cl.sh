#!/usr/bin/bash
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/cl-$VER)}
hg clone https://vc.compiler.company/cl $TARGETDIR
pushd $TARGETDIR
make
sudo make install
popd
