#!/bin/sh
set -e
cd .stash/src/sbcl
sh clean.sh
cd ..
tar -I 'zstd' -cf ../../dist/sbcl-source.tar.zst --exclude .git sbcl
