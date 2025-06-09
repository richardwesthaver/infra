#!/usr/bin/env bash
set -e
CPUS=$(getconf _NPROCESSORS_ONLN)
TARGETDIR="${1:-.stash/src/emacs}"
CONFIG=(--with-mailutils
	--with-imagemagick
	--without-pop
        --with-tree-sitter
	--without-sound
	--enable-link-time-optimization
	--with-modules
	--disable-gc-mark-trace)
cd "$TARGETDIR"
./configure "${CONFIG[@]}"
NATIVE_FULL_AOT=1 make -j"$CPUS"
