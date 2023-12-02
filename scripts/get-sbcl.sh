#!/usr/bin/bash
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/src/sbcl-$VER)}
git clone https://vc.compiler.company/packy/shed/vendor/sbcl.git $TARGETDIR
