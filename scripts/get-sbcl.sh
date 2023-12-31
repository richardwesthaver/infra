#!/usr/bin/env bash
# get SBCL source code
TARGETDIR=${1:-build/src/sbcl}
git clone https://vc.compiler.company/packy/shed/vendor/sbcl.git $TARGETDIR
