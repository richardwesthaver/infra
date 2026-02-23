#!/bin/sh
set -ex
mkdir -pv .stash/cache/tmp
TARGET="${1:-x86_64-unknown-linux-gnu}"
cd .stash/cache/tmp
pack="${PACKY_HOME}/dist/${TARGET}/core.zst"
if [ ! -d "core" ]; then
  case $PACKY_URL in
    "http"*) curl -O $pack ;;
    *) cp $pack ./ ;;
  esac
  unzstd core.zst
fi
cd core
# mv bin/* ${PREFIX}/bin/
mv core ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/core
links="skel homer mpk"
for i in $links; do
  ln -sf ${PREFIX}/bin/core ${PREFIX}/bin/$i
  echo "${PREFIX}/bin/$i -> ${PREFIX}/bin/core"
done
# mv libtree-sitter-alien.so libzstd-alien.so ${PREFIX}/lib/
# mv share/* ${PREFIX}/share/
