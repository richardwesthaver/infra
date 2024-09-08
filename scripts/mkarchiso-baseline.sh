#!/bin/sh
WD="${1:-.stash/box}"
PROFILE=".stash/src/box"
mkdir -pv $WD/baseline

hg clone https://vc.compiler.company/infra/box $PROFILE
pushd $PROFILE
hg up baseline
popd
sudo mkarchiso -v -w $(realpath $WD/baseline) -o $WD $PROFILE
