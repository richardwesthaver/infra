#!/usr/bin/env bash
TARGETDIR=${1:-build/cl}
hg clone https://vc.compiler.company/cl $TARGETDIR
pushd $TARGETDIR
make
# sudo make install
popd
