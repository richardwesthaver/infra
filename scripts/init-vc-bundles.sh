#!/bin/bash

# given a directory bundle files (.hg), unbundle and replace
# the files with bare directories.

DIR="${1:-/home/vc/src/}"
cd $DIR
echo "entering $DIR"
for i in $(find . -type f -name "*.hg"); do
  echo "unbundling $i"
  r=$(basename "$i" .hg)
  hg init "$r"
  cd "$r" && hg unbundle "$DIR/$i" && cd "$DIR"
  rm "$i"
done
cd $DIR/packy
for i in $(find . -type f -name "*.git"); do
  echo "unbundling $I"
  r=$(basename "$i" .git)
  git init "$r"
  cd "$r" && git fetch "$DIR/packy/$i" && cd "$DIR/packy"
  rm "$i"
done
