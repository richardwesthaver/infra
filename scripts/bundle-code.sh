#!/bin/sh
# bundle The Compiler Company source code
OUT="${2:-/tmp/dist}"
SRC_PATH="$OUT/../.stash/src/code"
BUNDLE_NAME="${1:-code}"
echo "Bundling $BUNDLE_NAME in $OUT..."
SOURCES="${3:-org core infra demo}"
rm -rf $OUT/bundle
mkdir -pv $OUT/bundle
mkdir -pv $OUT/vc/{zst,stream}

cd $SRC_PATH
# Find all mercurial repositories, create bundles and dump them to $OUT dir.
for i in $SOURCES; do
    echo ""
    echo "found hg repo: $i"
    cd $i
    echo "making zstd-v2 bundle..."
    hg bundle -a -t zstd-v2 $OUT/vc/zst/$(basename $(hg root)).hg.zst
    echo "making none-v2 bundle..."
    hg bundle -a -t none-v2 $OUT/vc/$(basename $(hg root)).hg
    echo "making stream bundle..."
    hg debugcreatestreamclonebundle $OUT/vc/stream/$(basename $(hg root)).hg.stream
    echo "... Done."
    cd ..
done

# archive all *.hg bundles, final compression with zst
cd $OUT/vc && tar -I 'zstd' -cf $OUT/bundle/$BUNDLE_NAME.tar.zst *.hg
# tar -cf $OUT/$BUNDLE_NAME.tar.stream vc/stream/*.hg.stream
# tar -cf $OUT/$BUNDLE_NAME.tar vc/*.hg
echo "Done."
