#!/bin/sh
set -e
cd build/src
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/core.tar.zst
unzstd core.tar.zst
tar -xvf core.tar
cd core
install -m 755 bin/* /usr/local/bin/
install -m 755 fasl/* /usr/local/lib/sbcl/
