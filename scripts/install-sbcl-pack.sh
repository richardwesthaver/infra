#!/bin/sh
cd build/src 
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/sbcl-binary.tar.zst
unzstd sbcl-binary.tar.zst
tar -xvf sbcl-binary.tar.zst
cd sbcl
sh install.sh
