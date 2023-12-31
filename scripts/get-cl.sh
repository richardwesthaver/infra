#!/usr/bin/env bash
TARGETDIR=${1:-$(realpath build/cl)}
hg clone https://vc.compiler.company/cl $TARGETDIR
pushd $TARGETDIR
make
# sudo make install
popd
