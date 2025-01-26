#!/bin/sh
set -e
TARGET="${1:-x86_64-unknown-linux-gnu}"
cd .stash/tmp
if [ ! -d "sbcl" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  pack="${PACKY_URL}/dist/${TARGET}/sbcl.tar.zst"
  if [[ "$PACKY_URL" =~ '^https?://([^/]+)' ]]; then
    curl -O $pack
  else
    cp $pack ./
  fi
  unzstd sbcl.tar.zst
  tar -xvf sbcl.tar
fi
cd sbcl
sh install.sh
