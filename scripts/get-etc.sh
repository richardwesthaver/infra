#!/bin/bash
TARGETDIR=${1:-build/etc}
hg clone https://vc.compiler.company/comp/etc $TARGETDIR
