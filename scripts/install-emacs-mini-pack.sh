#!/bin/sh
set -e
cd .stash/tmp
TARGET="${1:-x86_64-unknown-linux-gnu}"
curl -O "https://packy.compiler.company/dist/${TARGET}/pack/emacs-mini-binary.tar.zst"
unzstd emacs-mini-binary.tar.zst
tar -xvf emacs-mini-binary.tar
cd emacs*/
./configure --without-all --with-x-toolkit=no --without-x --enable-link-time-optimization \
            --with-json=ifavailable --with-gif=ifavailable --with-modules --with-gnutls=ifavailable \
            --with-zlib --with-native-compilation --prefix=/usr/local
make install
