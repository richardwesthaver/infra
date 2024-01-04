#!/usr/bin/env bash
CPUS=$(getconf _NPROCESSORS_ONLN)
TARGETDIR=${1:-build/src/emacs}
CONFIG=(--without-pop
	--without-sound
	--with-json
	--enable-link-time-optimization
	--with-modules)
pushd $TARGETDIR
./autogen.sh
$TARGETDIR/configure ${CONFIG[@]} 
NATIVE_FULL_AOT=1 make -j$CPUS
popd
