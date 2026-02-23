#!/bin/sh
set -e
VERSION="${2:-31.0.50}"
cd .stash/cache/tmp
if [ ! -d "emacs-${VERSION}" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  pack="${PACKY_HOME}/dist/${TARGET}/emacs.tar.zst"
  case $PACKY_URL in
    "http"*) curl -O $pack ;;
    *) cp $pack ./ ;;
  esac
  unzstd emacs.tar.zst
  tar -xvf emacs.tar
fi
cd "emacs-${VERSION}"
make install
