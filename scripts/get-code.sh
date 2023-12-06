#!/bin/bash
# Get The Compiler Company source code
SRC="${1:-comp}"
OUT=build/comp-$(date "+%Y%m%d")
mkdir -pv $OUT
pushd $OUT 
wget https://packy.compiler.company/bundle/src/$SRC.tar.zst 
unzstd $SRC.tar.zst
tar -xvf $SRC.tar
rm -rf $SRC.tar.zst $SRC.tar
for f in $(find . -name *.hg.zst); do
  echo "";
  echo $f;
  hg clone $f $(basename "$f" .hg.zst)
  echo "... Done.";
done
popd
