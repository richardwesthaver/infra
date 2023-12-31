#!/usr/bin/env bash
# get Emacs source code
TARGETDIR=${1:-$(realpath build/src/emacs)}
git clone https://vc.compiler.company/packy/shed/vendor/emacs.git $TARGETDIR
