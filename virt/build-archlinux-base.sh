#!/usr/bin/bash
id=$(buildah from --pull archlinux:latest)
buildah add $id etc/skel /etc/skel
buildah run $id useradd -ms /bin/bash alik
buildah run $id useradd -ms /bin/bash demon
buildah run --net host $id pacman-key --init
buildah run --net host $id pacman -Syu gnupg openssh mercurial sqlite tmux btrfs-progs liburing wireguard-tools --noconfirm
buildah run $id mkdir /usr/share/lisp
buildah run $id mkdir /usr/local/share/lisp
buildah config --annotation archlinux $id
buildah config --author='Richard Westhaver' $id
buildah copy $id etc/sbclrc /etc/sbclrc
buildah commit $id archlinux-base
