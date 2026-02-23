#!/bin/sh
set -ex
cd .stash/cache/tmp
unzstd core.zst
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
