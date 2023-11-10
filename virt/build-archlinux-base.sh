#!/usr/bin/bash
id=$(buildah from --pull archlinux:latest)
buildah run $id useradd -ms /bin/bash alik
buildah run $id useradd -ms /bin/bash demon
buildah run $id mkdir -p /usr/src/comp /var/local/lab /data
buildah run --net host $id pacman-key --init
buildah run --net host $id pacman -Syu git mercurial caddy --noconfirm
buildah config --workingdir /var/local $id
buildah config --annotation archlinux --env PATH=$PATH $id
buildah config --author='Richard Westhaver' --domainname 'compiler.company'$id
buildah commit $id archlinux-base
