#!/bin/sh
set -e
cd build/src 
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/nu.zst
unzstd nu.zst
mv nu /usr/local/bin/
