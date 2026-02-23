#!/bin/sh
set -e
TARGET="${1:-x86_64-unknown-linux-gnu}"
VERSION="${2:-31.0.50}"
pack="${PACKY_HOME}/dist/${TARGET}/emacs-mini.tar.zst"
cd .stash/cache/tmp
if [ ! -d "core" ]; then
  case $PACKY_URL in
    "http"*) curl -O $pack ;;
    *) cp $pack ./ ;;
  esac
  unzstd emacs-mini.tar.zst
  tar -xvf emacs-mini.tar
fi
cd "emacs-${VERSION}"
make install
