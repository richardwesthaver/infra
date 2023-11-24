#!/usr/bin/bash
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/sbcl-$VER)}
git clone https://vc.compiler.company/packy/shed/vendor/sbcl.git $TARGETDIR
pushd $TARGETDIR
make
sudo make install
popd
