#!/bin/bash
TARGETDIR=${1:-.stash/etc}
hg clone https://vc.compiler.company/comp/etc $TARGETDIR
