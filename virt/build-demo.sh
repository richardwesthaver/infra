#!/usr/bin/env bash
id=$(buildah from alpine-base)
buildah copy $id etc/skel /etc/skel
buildah run $id adduser demo -D
buildah config --workingdir /home/demo $id
buildah config -l=demo $id
# buildah config --entrypoint 
buildah commit $id demo
