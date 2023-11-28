#!/usr/bin/bash

#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#rustup update
#rustup default nightly

VER="${1:-main}"
TARGETDIR=${2:-$(realpath build/rust-$VER)}
git clone https://vc.compiler.company/packy/shed/vendor/rust.git $TARGETDIR
