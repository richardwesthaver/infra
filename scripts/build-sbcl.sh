#!/bin/sh
cd .stash/src/sbcl
echo \""2.4.6:$(git rev-parse --short HEAD)"\" > version.lisp-expr
./make.sh --dynamic-space-size=8Gb --without-gencgc --with-mark-region-gc --fancy --with-sb-fasteval --without-sb-eval
