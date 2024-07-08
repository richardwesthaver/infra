#!/bin/sh
CPUS=$(getconf _NPROCESSORS_ONLN)
TARGETDIR="${1:-.stash/src/emacs}"
cd $TARGETDIR
./configure --without-all --with-x-toolkit=no --without-x --enable-link-time-optimization \
            --with-json=ifavailable --with-gif=ifavailable --with-modules --prefix=/usr/local
NATIVE_FULL_AOT=1 make -j$CPUS
