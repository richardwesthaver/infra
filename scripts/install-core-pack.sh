#!/bin/sh
set -e
TARGET="${1:-x86_64-unknown-linux-gnu}"
cd .stash/tmp
pack="${PACKY_HOME}/dist/${TARGET}/core.tar.zst"
if [ ! -d "core" ]; then
  case $PACKY_URL in
    "http"*) curl -O $pack ;;
    *) cp $pack ./ ;;
  esac
  unzstd core.tar.zst
  tar -xvf core.tar
fi
cd core
# mv bin/* ${PREFIX}/bin/
mv core ${PREFIX}/bin/
links="skel homer packy rdb organ vc gen swm"
for i in $links; do
  ln -sf ${PREFIX}/bin/core ${PREFIX}/bin/$i
  echo "${PREFIX}/bin/$i -> ${PREFIX}/bin/core"
done
mv libtree-sitter-alien.so libzstd-alien.so ${PREFIX}/lib/
# mv share/* ${PREFIX}/share/
