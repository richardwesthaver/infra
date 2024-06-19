#!/bin/sh
set -e
name="${1:-emacs}"
cd .stash/src/emacs
./make-dist --tar --no-compress
zstd -22 "${name}*.tar" -o "../../${name}.tar.zst"
