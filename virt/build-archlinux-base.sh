#!/usr/bin/bash
id=$(buildah from --pull archlinux:latest)
buildah run $id useradd -ms /bin/bash alik
buildah run $id useradd -ms /bin/bash demon
buildah run --net host $id pacman-key --init
buildah run --net host $id pacman -Syu gnupg openssh mercurial sqlite tmux btrfs-progs liburing wireguard-tools --noconfirm
buildah config --annotation archlinux $id
buildah config --author='Richard Westhaver' $id
buildah commit $id archlinux-base
