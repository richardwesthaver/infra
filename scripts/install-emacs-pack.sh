#!/bin/sh
set -e
VERSION="${2:-31.0.50}"
cd .stash/tmp
if [ ! -d "emacs-${VERSION}" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  pack="${PACKY_URL}/dist/${TARGET}/emacs.tar.zst"
  if [[ "$PACKY_URL" =~ ^https?://([^/]+) ]]; then
    curl -O $pack
  else
    cp $pack ./
  fi
  unzstd emacs.tar.zst
  tar -xvf emacs.tar
fi
cd "emacs-${VERSION}"
make install
