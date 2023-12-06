#!/usr/bin/bash

# get rust source code

# You may want to have an upstream rust compiler on hand:

#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#rustup update
#rustup default nightly

VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/src/rust-$VER)}
git clone https://vc.compiler.company/packy/shed/vendor/rust.git $TARGETDIR
