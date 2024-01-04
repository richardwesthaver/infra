#!/usr/bin/env bash
id=$(buildah from ci-worker)
buildah run $id adduser $USER -D
buildah config --volume /mnt/y $id
# save a fresh core
buildah config --workingdir /infra $id
buildah run --net host $id make operator
buildah config --workingdir /home/$USER $id
buildah config --entrypoint '["/usr/local/bin/sbcl", "--core", "/usr/local/lib/sbcl/prelude.fasl"]' $id
buildah commit $id ci-operator
