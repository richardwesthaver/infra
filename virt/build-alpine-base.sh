#!/usr/bin/env bash
id=$(buildah from --pull alpine:latest)
buildah run --net host $id apk add --no-cache openssh mercurial wireguard-tools
buildah config --annotation alpine $id
buildah config --author='Richard Westhaver' $id
buildah commit $id alpine-base
