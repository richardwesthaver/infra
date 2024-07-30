#!/bin/sh
name="${1:-emacs-31.0.50}"
cd .stash/src/emacs
./make-dist --tar --no-compress
zstd -8 "${name}.tar" -o "../../emacs.tar.zst"
