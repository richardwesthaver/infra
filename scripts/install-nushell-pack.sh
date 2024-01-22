#!/bin/sh
set -e
cd build/src 
mkdir nushell && cd nushell
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/nushell.tar.zst
unzstd nushell.tar.zst
tar -xvf nushell.tar
rm -rf nushell.tar*
install -m 755 ./nu* /usr/local/bin/

