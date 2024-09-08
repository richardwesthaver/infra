#!/bin/sh
WD="${1:-.stash/box}"
PROFILE=".stash/src/box"
mkdir -pv $WD/releng
hg clone https://vc.compiler.company/infra/box $PROFILE
pushd $PROFILE
hg up releng
popd
sudo mkarchiso -v -w $(realpath $WD/releng) -o $WD $PROFILE
