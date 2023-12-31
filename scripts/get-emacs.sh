#!/usr/bin/env bash
# get Emacs source code
TARGETDIR=${1:-build/src/emacs}
git clone https://vc.compiler.company/packy/shed/vendor/emacs.git $TARGETDIR
