#!/usr/bin/env bash
TARGETDIR=${1:-.stash/src/cl}
hg clone https://vc.compiler.company/comp/cl $TARGETDIR
pushd $TARGETDIR
make
# sudo make install
popd
