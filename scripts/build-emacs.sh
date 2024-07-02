#!/usr/bin/env bash
CPUS=$(getconf _NPROCESSORS_ONLN)
TARGETDIR="${1:-.stash/src/emacs}"
CONFIG=(--with-mailutils
	--with-imagemagick
	--with-x-toolkit=gtk
	--without-pop
        --with-tree-sitter
	--without-sound
	--with-json
	--enable-link-time-optimization
	--with-modules)
cd $TARGETDIR
./configure ${CONFIG[@]} 
NATIVE_FULL_AOT=1 make -j$CPUS
