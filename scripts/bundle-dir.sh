#!/usr/bin/env bash
# bundle a tar.zst archive of Mercurial repositories.
WD=/mnt/y/data/packy
#WD=$(realpath dist)
OUT=$WD/bundle/src
SRC_PATH=$HOME/dev/comp
BUNDLE_NAME="${1:-comp}"
echo "Bundling $BUNDLE_NAME in $OUT..."

rm -rf $OUT/*
mkdir -pv $OUT
mkdir -pv $WD/vc/{zst,stream}

pushd $SRC_PATH
# Find all mercurial repositories, create bundles and dump them to $OUT dir.
for i in $(find . -name ".hg" | cut -c 3-); do
    echo ""
    echo "found hg repo: $i"
    cd "$i"
    cd ..
    echo "making zstd-v2 bundle..."
    hg bundle -a -t zstd-v2 $WD/vc/zst/$(basename $(hg root)).hg.zst
    echo "making none-v2 bundle..."
    hg bundle -a -t none-v2 $WD/vc/$(basename $(hg root)).hg
    echo "making stream bundle..."
    hg debugcreatestreamclonebundle $WD/vc/stream/$(basename $(hg root)).hg.stream
    echo "... Done."
    cd $SRC_PATH
done
popd
pushd $WD
# archive all *.hg.zst bundles, final compression with zst
tar -I 'zstd' -cf $OUT/$BUNDLE_NAME.tar.zst vc/zst/*.hg.zst
# tar -cf $OUT/$BUNDLE_NAME.tar.stream vc/stream/*.hg.stream
# tar -cf $OUT/$BUNDLE_NAME.tar vc/*.hg
echo "Done."
popd
