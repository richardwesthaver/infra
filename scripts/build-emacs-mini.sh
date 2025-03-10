#!/bin/sh
set -e
CPUS=$(getconf _NPROCESSORS_ONLN)
TARGETDIR="${1:-.stash/src/emacs}"
cd "$TARGETDIR" && ./autogen.sh && \
./configure --without-all --with-x-toolkit=no --without-x --enable-link-time-optimization \
            --with-gif=ifavailable --with-modules --with-gnutls=ifavailable \
            --with-zlib --prefix=/usr/local \
	    --disable-gc-mark-trace
NATIVE_FULL_AOT=1 make -j"$CPUS"
