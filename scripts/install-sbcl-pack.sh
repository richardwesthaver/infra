#!/bin/sh
set -e
TARGET="${1:-x86_64-unknown-linux-gnu}"
cd .stash/src 
curl -O "https://packy.compiler.company/dist/${TARGET}/sbcl.tar.zst"
unzstd sbcl.tar.zst
tar -xvf sbcl.tar
cd sbcl
sh install.sh
