#!/bin/sh
set -e
cd .stash/src
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/emacs-mini.tar.zst
unzstd emacs-mini.tar.zst
tar -xvf emacs-mini.tar
cd emacs
make install
