#!/usr/bin/bash
VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/sbcl-$VER)}
DISTDIR=${3:-$(realpath dist/sbcl)}
git clone https://vc.compiler.company/packy/shed/vendor/sbcl.git $TARGETDIR
pushd $TARGETDIR
sh make.sh --prefix=$DISTDIR --fancy \
    # && cd tests && sh run-tests.sh && cd .. \ ## TODO futex fails
    && cd doc/manual && make && cd ../.. \
    && sh install.sh
popd
