#!/usr/bin/env bash
CPUS=$(getconf _NPROCESSORS_ONLN)
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/src/emacs-$VER)}
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
