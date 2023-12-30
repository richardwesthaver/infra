#!/usr/bin/env bash
CPUS=$(getconf _NPROCESSORS_ONLN)
TARGETDIR=${1:-$(realpath build/src/emacs)}
CONFIG=(--with-mailutils
	--with-imagemagick
	--with-x-toolkit=gtk
	--without-pop
	--without-sound
	--with-json
	--enable-link-time-optimization
	--with-native-compilation
	--with-modules)
pushd $TARGETDIR
./autogen.sh
$TARGETDIR/configure ${CONFIG[@]} 
NATIVE_FULL_AOT=1 make -j$CPUS
popd
