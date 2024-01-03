#!/usr/bin/env bash
id=$(buildah from ci-worker)
buildah add $id etc/skel /etc
buildah run $id adduser $USER -D
buildah config --workingdir /home/$USER $id
buildah config --volume /mnt/y $id
buildah config --entrypoint '["/usr/local/bin/sbcl", "--core", "/usr/local/lib/sbcl/prelude.fasl"]' $id
buildah commit $id ci-operator
