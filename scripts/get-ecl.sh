#!/usr/bin/env bash
# get ECL source code
TARGETDIR=${1:-build/src/ecl}
git clone https://vc.compiler.company/packy/ecl.git $TARGETDIR
