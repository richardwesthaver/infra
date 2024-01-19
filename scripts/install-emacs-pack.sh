#!/bin/sh
set -e
cd build/src
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/emacs-binary.tar.zst
unzstd emacs-binary.tar.zst
tar -xvf emacs-binary.tar
cd emacs
make install
