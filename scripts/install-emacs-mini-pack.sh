#!/bin/sh
set -e
cd .stash/tmp
TARGET="${1:-x86_64-unknown-linux-gnu}"
curl -O "https://packy.compiler.company/dist/${TARGET}/pack/emacs-mini.tar.zst"
unzstd emacs-mini.tar.zst
tar -xvf emacs-mini.tar
cd emacs
make install
