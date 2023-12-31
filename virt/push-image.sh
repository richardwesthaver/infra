#!/usr/bin/env bash
buildah push --compression-format zstd "${1}" "dir:/mnt/y/data/packy/container/docker/${1}"
buildah push --compression-format zstd "${1}" "oci:/mnt/y/data/packy/container/oci:${1}:latest"
