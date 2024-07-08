#!/bin/sh
CPUS=$(getconf _NPROCESSORS_ONLN)
TARGETDIR="${1:-.stash/src/emacs}"
cd $TARGETDIR && ./autogen.sh && \
./configure --without-all --with-x-toolkit=no --without-x --enable-link-time-optimization \
            --with-json=ifavailable --with-gif=ifavailable --with-modules --with-gnutls=ifavailable \
            --prefix=/usr/local && \
NATIVE_FULL_AOT=1 make -j$CPUS
