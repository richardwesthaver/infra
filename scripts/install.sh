#!/bin/bash
set -ex
dir=".stash/tmp/${1}"
mkdir -pv "$dir"
curl -o "$dir/PKGBUILD" "https://packy.compiler.company/pkg/build/${1}"
pushd "$dir"
makepkg -si
popd
