#!/bin/sh
WD="${1:-.stash/box}"
PROFILE=".stash/src/box"
mkdir -pv $WD/releng
hg clone https://vc.compiler.company/comp/box $PROFILE && cd $PROFILE && hg up releng
sudo mkarchiso -v -w $WD/releng -o $WD $PROFILE
