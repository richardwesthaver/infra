#!/usr/bin/env bash
# get SBCL source code
TARGETDIR=${1:-.stash/src/sbcl}
git clone https://vc.compiler.company/packy/sbcl.git $TARGETDIR
