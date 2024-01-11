#!/usr/bin/env bash
# Get The Compiler Company source code
SRC="${1:-code}"
OUT=build/src/$SRC
mkdir -pv $OUT
cd $OUT
wget -nc https://packy.compiler.company/bundle/$SRC.tar.zst 
unzstd $SRC.tar.zst
tar -xvf $SRC.tar
rm -rf $SRC.tar
repos=`ls *.hg`
for f in $repos; do
  echo "cloning repo: $f"
  rep=`basename $f .hg`
  if [ -d $rep ]; then
    echo "$rep already exists"
  else
    hg clone $f $(basename $f .hg)
  fi
done
echo "... Done."
