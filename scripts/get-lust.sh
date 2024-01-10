#!/usr/bin/env bash
# install the Lonely Rust compiler source code
TARGETDIR=${1:-build/lust}
hg clone https://vc.compiler.company/comp/lust $TARGETDIR
pushd $TARGETDIR
make
sudo make install
popd
