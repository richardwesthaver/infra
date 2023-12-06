#!/usr/bin/bash
id=$(buildah from archlinux-base)
# buildah add $id /mnt/y/lab /var/local/lab
buildah run $id useradd -ms /bin/bash $USER
buildah run $id mkdir -p /home/$USER/lab /var/local/data
buildah run --net host $id pacman -Syu git sbcl base-devel zstd --noconfirm
buildah run --net host $id hg clone https://vc.compiler.company/comp/core /usr/src/core
buildah run --net host $id hg clone https://vc.compiler.company/comp/infra /usr/src/infra
buildah config --workingdir /home/$USER $id
buildah commit $id box-base
