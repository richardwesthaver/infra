#!/usr/bin/env bash
cd build/src 
curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/sbcl-2.4.0-x86-64-linux-binary.tar.bz2
bzip2 -cd sbcl-2.4.0-x86-linux-binary.tar.bz2 | tar xvf -
cd sbcl-2.4.0-x86-64-linux
sh install.sh
