#!/bin/sh
set -e
cd .stash/tmp
if [ ! -d "tree-sitter-langs" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  pack="${PACKY_HOME}/dist/${TARGET}/tree-sitter-langs.tar.zst"
  case $PACKY_URL in
    "http"*) curl -O $pack ;;
    *) cp $pack ./ ;;
  esac
  unzstd tree-sitter-langs.tar.zst
  tar -xvf tree-sitter-langs.tar
fi
cd tree-sitter-langs
cp -rf ./* /usr/local/
