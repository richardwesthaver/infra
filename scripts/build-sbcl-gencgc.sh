#!/bin/sh
cd .stash/src/sbcl
echo \""2.4.6:$(git rev-parse --short HEAD)"\" > version.lisp-expr
./make.sh --fancy
