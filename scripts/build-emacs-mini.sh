#!/usr/bin/env bash
CPUS=$(getconf _NPROCESSORS_ONLN)
TARGETDIR="${1:-build/src/emacs}"
CONFIG=(--without-all
        --without-x
	--enable-link-time-optimization
	--with-json
	--with-modules
        --prefix=/usr/local)
cd $TARGETDIR &&./configure ${CONFIG[@]} && NATIVE_FULL_AOT=1 make -j$CPUS
