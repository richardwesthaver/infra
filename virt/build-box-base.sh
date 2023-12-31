#!/usr/bin/env bash
id=$(buildah from archlinux-base)
# buildah add $id /mnt/y/lab /var/local/lab
buildah run $id useradd -ms /bin/bash $USER
buildah run $id mkdir -p /home/$USER/lab /var/local/data
buildah run --net host $id pacman -Syu make git base-devel zstd llvm curl --noconfirm
buildah config --workingdir /home/$USER $id
buildah run --net host $id hg clone https://vc.compiler.company/comp/core
buildah run --net host $id hg clone https://vc.compiler.company/comp/infra
buildah commit $id box-base
