#!/bin/sh
set -e
cd build/src
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/emacs-mini-binary.tar.zst
unzstd emacs-mini-binary.tar.zst
tar -xvf emacs-mini-binary.tar
cd emacs
make install
