#!/bin/sh
set -e

cd .stash/tmp
if [ ! -f "core" ]; then
  TARGET="${1:-x86_64-unknown-linux-gnu}"
  pack="${PACKY_URL}/dist/${TARGET}/core.zst"
  case $PACKY_URL in
    "http"*) curl -O $pack ;;
    *) cp $pack ./ ;;
  esac
  unzstd core.zst
fi

sh ../../scripts/link-core.sh core
