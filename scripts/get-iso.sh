#!/bin/sh
IMG="${1:-releng}"
OUT_FILE="$IMG-x86_64.iso"
OUT=".stash/box"
mkdir -pv $OUT
cd $OUT && curl -O "https://packy.compiler.company/box/$OUT_FILE"
