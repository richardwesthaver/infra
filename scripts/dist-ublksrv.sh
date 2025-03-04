#!/bin/sh
cd .stash
mkdir -pv ublksrv/include
cp src/ublksrv/include/*.h  ublksrv/include/
cp src/ublksrv/lib/.libs/libublksrv.so* src/ublksrv/ublk ublksrv/
tar -I 'zstd' -cf ublksrv.tar.zst ublksrv
rm -rf ublksrv
