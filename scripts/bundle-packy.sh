#!/usr/bin/env bash
# bundle a tar.zst archive of git repositories.
# must be absolute
BUNDLE="${1:-packy}"
WD=$(realpath .stash)
OUT=$WD
SRC_PATH=$HOME/src/$BUNDLE

echo "Bundling $BUNDLE_NAME in $OUT..."

mkdir -pv $OUT
mkdir -pv $WD/vc/{git,hg}

cd $SRC_PATH
# Find all git repositories, create bundles and dump them to $OUT dir.
for i in $(find . -name ".git" | cut -c 3-); do
    echo ""
    echo "found git repo: $i"
    cd $i/..
    echo "making git bundle..."
    git bundle create $WD/vc/git/$(basename $(realpath .)).git --all
    echo "... Done."
    cd $SRC_PATH
done

for i in $(find . -name ".hg" | cut -c 3-); do
    echo ""
    echo "found hg repo: $i"
    cd $i/..
    echo "making none-v2 bundle..."
    hg bundle -a -t none-v2 $WD/vc/hg/$(basename $(hg root)).hg
    echo "... Done."
    cd $SRC_PATH
done

# archive all *.git bundles and Mercurial .hg bundle
cd $WD/vc && tar -I 'zstd' -cf $OUT/$BUNDLE.tar.zst git/*.git hg/hg.hg
echo "Done."
