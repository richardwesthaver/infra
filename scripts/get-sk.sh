#!/bin/sh
set -e
OUT="${1:-.stash}"
mkdir -pv $OUT
cd $OUT && curl -O https://packy.compiler.company/dist/x86_64-unknown-linux-gnu/bin/sk && chmod +x sk

