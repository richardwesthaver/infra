#!/usr/bin/bash
CPUS=$(shell getconf _NPROCESSORS_ONLN)
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/emacs-$VER)}
DISTDIR=${3:-$(realpath dist/emacs-$VER)}
CONFIG=(--with-mailutils
	--with-imagemagick
	--with-x-toolkit=gtk
	--without-pop
	--without-sound
	--with-json
	--enable-link-time-optimization
	--with-native-compilation
	--with-modules)

git clone https://vc.compiler.company/packy/shed/vendor/emacs.git $TARGETDIR
pushd $TARGETDIR
./autogen.sh
mkdir -pv $DISTDIR
pushd $DISTDIR
$TARGETDIR/configure ${CONFIG[@]} 
NATIVE_FULL_AOT=1 make -j$CPUS
# make install
popd
popd
