#!/bin/sh
set -e

cd .stash/tmp
if [ ! -f "core" ]; then
   TARGET="${1:-x86_64-unknown-linux-gnu}"
   pack="${PACKY_URL}/dist/${TARGET}/core.zst"
   if [[ "$PACKY_URL" =~ ^https?://([^/]+) ]]; then
     curl -O $pack
   else
     cp $pack ./
   fi
   unzstd core.zst
fi

sh ../../scripts/link-core.sh core
