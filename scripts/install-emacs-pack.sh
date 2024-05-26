#!/bin/sh
set -e
cd .stash/src
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/emacs.tar.zst
unzstd emacs.tar.zst
tar -xvf emacs.tar
cd emacs
make install
