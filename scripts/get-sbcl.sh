#!/usr/bin/env bash
# get SBCL source code
TARGETDIR=${1:-.stash/src/sbcl}
git clone https://github.com/sbcl/sbcl $TARGETDIR # https://vc.compiler.company/packy/sbcl 
