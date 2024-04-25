#!/bin/sh
set -e
cd build/src 
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/sbcl.tar.zst
unzstd sbcl.tar.zst
tar -xvf sbcl.tar
cd sbcl
sh install.sh
