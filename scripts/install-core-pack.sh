#!/bin/sh
set -e
TARGET="${1:-x86_64-unknown-linux-gnu}"
cd .stash/tmp
curl -O "https://packy.compiler.company/dist/${TARGET}/pack/core.tar.zst"
unzstd core.tar.zst
tar -xvf core.tar
cd core
install -m 755 bin/* /usr/local/bin/
install -m 755 fasl/* /usr/local/lib/sbcl/
