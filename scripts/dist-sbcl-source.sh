#!/bin/sh
set -e
cd .stash/src/sbcl
sh clean.sh
cd ..
tar -I 'zstd' -cf sbcl-source.tar.zst --exclude .git sbcl
mv sbcl-source.tar.zst ../
