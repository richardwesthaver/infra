#!/usr/bin/bash
TIMESTAMP=$(date +%s)
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/emacs-$VER)}
DISTDIR=${3:-$(realpath dist/emacs-$VER-$TIMESTAMP)}
CONFIG=(--with-mailutils
	--with-imagemagick
	--with-x-toolkit=gtk
	--without-pop
	--without-sound
	--with-json
	--enable-link-time-optimization
	--with-native-compilation
	--with-modules)

git clone https://lab.rwest.io/packy/shed/vendor/emacs.git $TARGETDIR
pushd $TARGETDIR
./autogen.sh
mkdir -p $DISTDIR
pushd $DISTDIR
$TARGETDIR/configure ${CONFIG[@]} 
NATIVE_FULL_AOT=1 make -j8
# make install
popd
popd
