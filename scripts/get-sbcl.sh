#!/usr/bin/env bash
# get SBCL source code
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/src/sbcl)}
git clone https://vc.compiler.company/packy/shed/vendor/sbcl.git $TARGETDIR
