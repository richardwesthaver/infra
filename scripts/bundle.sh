#!/bin/bash
# bundle a tar.zst archive of Mercurial repositories.
#WD=/mnt/y/data/packy
WD=$(realpath dist)
OUT=$WD/code
SRC_PATH=$HOME/dev/comp
BUNDLE_NAME=code
echo "Bundling $BUNDLE_NAME in $OUT..."

rm -rf $OUT/*
rm -rf $WD/$BUNDLE_NAME.*
mkdir -pv $OUT/{zst,stream}

pushd $SRC_PATH

# Find all mercurial repositories, create bundles and dump them to $OUT dir
for i in $(find . -name ".hg" | cut -c 3-); do
    echo "";
    echo $i;

    cd "$i";
    cd ..;
    hg bundle -a -t zstd-v2 $OUT/zst/$(basename $(hg root)).hg.zst;
    hg bundle -a -t none-v2 $OUT/$(basename $(hg root)).hg;
    hg debugcreatestreamclonebundle $OUT/stream/$(basename $(hg root)).hg.stream;
    echo "... Done.";
    cd $SRC_PATH
done
popd
pushd $WD
tar -I 'zstd --ultra -22' -cf $BUNDLE_NAME.tar.zst code/zst/*.hg.zst
tar -cf $BUNDLE_NAME.tar.stream code/stream/*.hg.stream
tar -cf $BUNDLE_NAME.tar code/*.hg
echo "Done."
popd
