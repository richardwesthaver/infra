#!/usr/bin/bash
# get Emacs source code
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/src/emacs-$VER)}
git clone https://vc.compiler.company/packy/shed/vendor/emacs.git $TARGETDIR
