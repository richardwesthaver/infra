#!/bin/sh
set -e
TARGETDIR="${1:-.stash/src/tree-sitter}"
PREFIX=$(realpath "${2:-${PREFIX:-/usr/local}}")
cp "$TARGETDIR/libtree-sitter.so" "$PREFIX/lib/"
cp -rf "$TARGETDIR/lib/include/*" "$PREFIX/include/"
