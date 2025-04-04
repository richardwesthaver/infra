#!/bin/sh
set -ex
cd .stash/src
cp -rf tree-sitter/lib/include tree-sitter/
tar -cf tree-sitter.tar tree-sitter/libtree-sitter.so* tree-sitter/include/*
zstd tree-sitter.tar
rm tree-sitter.tar
mv tree-sitter.tar.zst ../
