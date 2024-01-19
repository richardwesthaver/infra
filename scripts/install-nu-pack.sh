#!/bin/sh
set -e
cd build/src 
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/nu-binary.tar.zst
unzstd nu-binary.tar.zst
tar -xvf nu-binary.tar
cp nu /usr/local/bin/
