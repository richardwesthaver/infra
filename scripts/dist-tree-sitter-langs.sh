#!/bin/sh
set -ex
mkdir -pv .stash/cache/tmp/tree-sitter-langs/lib
mkdir -pv .stash/cache/tmp/tree-sitter-langs/share
./scripts/tree-sitter-langs.sh .stash/src/tree-sitter-langs .stash/cache/tmp/tree-sitter-langs
cd .stash/cache/tmp
tar -cf tree-sitter-langs.tar tree-sitter-langs
zstd tree-sitter-langs.tar
rm tree-sitter-langs.tar
rm -rf tree-sitter-langs/
mv tree-sitter-langs.tar.zst ../
