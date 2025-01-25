#!/bin/sh
PREFIX=${2:/usr/local}
mv ${1} ${PREFIX}/bin/
links="skel homer packy rdb organ vc gen swm"
for i in $links; do
  ln -sf ${PREFIX}/core ${PREFIX}/$i
  echo "${PREFIX}$i -> ${PREFIX}/core"
done
