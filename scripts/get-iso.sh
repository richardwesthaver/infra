#!/bin/sh
IMG="${1:-archlinux}"
OUT_FILE="$IMG-x86_64.iso"
OUT=".stash/"
cd $OUT && curl -O "https://packy.compiler.company/dist/$OUT_FILE"
