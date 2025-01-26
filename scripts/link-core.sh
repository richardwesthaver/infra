#!/bin/sh
PREFIX="${2:-/usr/local}"
mv ${1} ${PREFIX}/bin/
links="skel homer packy rdb organ vc gen swm"
for i in $links; do
  ln -sf ${PREFIX}/bin/core ${PREFIX}/bin/$i
  echo "${PREFIX}/bin/$i -> ${PREFIX}/bin/core"
done
