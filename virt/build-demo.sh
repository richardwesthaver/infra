#!/usr/bin/env bash
id=$(buildah from archlinux-base)
buildah run $id useradd -ms /bin/bash $USER
buildah run $id mkdir -p /home/$USER/lab /var/local/data
buildah run --net host $id pacman -Syu make git zstd curl sbcl base-devel llvm --noconfirm
buildah run --net host $id hg clone https://vc.compiler.company/comp/core /usr/src/core
buildah run --net host $id hg clone https://vc.compiler.company/comp/infra /usr/src/infra
buildah run --net host $id hg clone https://vc.compiler.company/comp/demo /usr/src/demo
buildah run --net host $id /bin/sh -c 'cd /usr/src/infra && make sbcl-install && make rocksdb-install && make ts-langs && make dist/fasl'
buildah run $id cp /usr/src/infra/dist/fasl/* /usr/local/lib/sbcl/
buildah config --workingdir /home/$USER $id
buildah commit $id demo
