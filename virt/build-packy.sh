#!/usr/bin/env bash
id=$(buildah from archlinux-base)
buildah run --net host $id pacman -Sy zstd-dev make git linux-headers openssl --noconfirm
# requires: rocksdb,zstd
# core dependencies: packy,packy-registry.service,krypt,alik,tz
buildah config -l=packy $id
buildah config --volume /store $id
buildah config --volume /stash $id
buildah config --volume /packy $id
# buildah config --entrypoint 
buildah commit $id packy
