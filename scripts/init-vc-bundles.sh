#!/bin/sh

# given a directory bundle files (.hg), unbundle and replace
# the files with bare directories.

DIR="${1:-/home/vc/src/}"
cd $DIR
for i in $(find . -type f -name ".hg"); do
  echo "unbundling $i"
  r=(basename "$i" .hg)
  hg init "$r"
  cd "$r" && hg unbundle "$DIR/$i" && cd "$DIR"
  rm "$i"
done
