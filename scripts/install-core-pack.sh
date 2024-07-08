#!/bin/sh
set -e
TARGET="${1:-x86_64-unknown-linux-gnu}"
cd .stash/tmp
curl -O "https://packy.compiler.company/dist/${TARGET}/pack/core.tar.zst"
unzstd core.tar.zst
tar -xvf core.tar
cd core
mv bin/* /usr/local/bin/
mv lib/* /usr/local/lib/
mv share/* /usr/local/share/
