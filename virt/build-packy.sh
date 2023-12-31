#!/usr/bin/env bash
id=$(buildah from alpine-base)
buildah copy $id etc/skel /etc/skel
buildah run $id adduser $USER -D
buildah run --net host $id apk add --no-cache zstd-dev make git linux-headers cargo openssl
# requires: rocksdb,zstd
# core dependencies: packy,packy-registry.service,krypt,alik,tz
buildah config --workingdir /home/demo $id --user $USER
buildah config -l=packy $id
# buildah config --entrypoint 
buildah commit $id packy
