#!/usr/bin/bash
id=$(buildah from archlinux-base)
buildah add $id /mnt/y/lab /var/local/lab
buildah config --workingdir /var/local/lab $id
buildah commit $id box-base
