#!/bin/sh
set -e
cd .stash/tmp
if [ ! -d "tree-sitter" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  pack="${PACKY_URL}/dist/${TARGET}/tree-sitter.tar.zst"
  case $PACKY_URL in
    "http"*) curl -O $pack ;;
    *) cp $pack ./ ;;
  esac
  unzstd tree-sitter.tar.zst
  tar -xvf tree-sitter.tar
fi
cd tree-sitter
cp libtree-sitter.so /usr/local/lib/
cp -rf include/* /usr/local/include/
