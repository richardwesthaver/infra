#!/bin/sh
set -e
mkdir -pv .stash/tmp/tree-sitter-langs/lib
mkdir -pv .stash/tmp/tree-sitter-langs/share
./scripts/tree-sitter-langs.sh .stash/src/tree-sitter-langs .stash/tmp/tree-sitter-langs
cd .stash/tmp
tar -cf tree-sitter-langs.tar tree-sitter-langs
zstd tree-sitter-langs.tar
rm tree-sitter-langs.tar
rm -rf tree-sitter-langs/
mv tree-sitter-langs.tar.zst ../
