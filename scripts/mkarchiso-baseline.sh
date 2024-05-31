#!/bin/sh
WD="${1:-.stash/box}"
PROFILE=".stash/src/box"
mkdir -pv $WD/baseline
hg clone https://vc.compiler.company/comp/box $PROFILE && cd $PROFILE && hg up baseline
sudo mkarchiso -v -w $WD/baseline -o $WD $PROFILE
