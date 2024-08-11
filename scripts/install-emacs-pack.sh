#!/bin/sh
set -e
TARGET="${1:-x86_64-unknown-linux-gnu}"
VERSION="${2:-31.0.50}"
cd .stash/tmp
curl -O "https://packy.compiler.company/dist/${TARGET}/pack/emacs.tar.zst"
unzstd emacs.tar.zst
tar -xvf emacs.tar
cd "emacs-${VERSION}"
make install
