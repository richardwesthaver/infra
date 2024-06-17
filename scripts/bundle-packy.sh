#!/usr/bin/env bash
# bundle a tar.zst archive of git repositories.
# must be absolute
BUNDLE="${1:-packy}"
WD=$(realpath .stash)
OUT=$WD
SRC_PATH=$HOME/src/$BUNDLE

echo "Bundling $BUNDLE_NAME in $OUT..."

mkdir -pv $OUT
mkdir -pv $WD/src/packy

cd $SRC_PATH
# Find all git repositories, create bundles and dump them to $OUT dir.
for i in $(find . -name ".git" | cut -c 3-); do
    echo ""
    echo "found git repo: $i"
    cd $i/..
    echo "making git bundle..."
    git bundle create $WD/src/packy/$(basename $(realpath .)).git --all
    echo "... Done."
    cd $SRC_PATH
done

for i in $(find . -name ".hg" | cut -c 3-); do
    echo ""
    echo "found hg repo: $i"
    cd $i/..
    echo "making none-v2 bundle..."
    hg bundle -a -t none-v2 $WD/src/packy/$(basename $(hg root)).hg
    echo "... Done."
    cd $SRC_PATH
done

# archive all *.git bundles and Mercurial .hg bundle
cd $WD/src
tar -cf $BUNDLE.tar packy/* && zstd --ultra $BUNDLE.tar && mv $BUNDLE.tar.zst $OUT
rm $BUNDLE.tar

echo "Done."
