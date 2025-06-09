#!/usr/bin/env bash
# Get The Compiler Company source code
SRC="${1:-code}"
OUT=.stash/src/$SRC
mkdir -pv "$OUT"
cd "$OUT" || exit
wget -nc "https://packy.compiler.company/src/$SRC.tar.zst"
unzstd "$SRC.tar.zst"
tar -xvf "$SRC.tar"
rm -rf "$SRC.tar"
repos=$(ls '*.hg')
for f in $repos; do
  echo "cloning repo: $f"
  rep=$(basename "$f" .hg)
  if [ -d "$rep" ]; then
    echo "$rep already exists"
  else
    hg clone "$f" "$(basename \\"$f\\" .hg)"
  fi
done
echo "... Done."
