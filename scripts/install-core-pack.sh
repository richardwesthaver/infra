#!/bin/sh
set -e
TARGET="${1:-x86_64-unknown-linux-gnu}"
cd .stash/tmp
pack="${PACKY_URL}/dist/${TARGET}/core.tar.zst"
if [[ "$PACKY_URL" =~ ^https?://([^/]+) ]]; then
  curl -O $pack
else
  cp $pack ./
fi
unzstd core.tar.zst
tar -xvf core.tar
cd core
mv bin/* ${PREFIX}/bin/
links="skel homer packy rdb organ vc gen swm"
for i in $links; do
  ln -sf ${PREFIX}/core ${PREFIX}/$i
  echo "${PREFIX}$i -> ${PREFIX}/core"
done

mv lib/* ${PREFIX}/lib/
mv share/* ${PREFIX}/share/
