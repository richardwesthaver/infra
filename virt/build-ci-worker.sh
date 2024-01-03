#!/usr/bin/env bash

# these should be spawned as needed by a ci-leader box within a
# dedicated pod named 'ci'.

id=$(buildah from alpine-base)
buildah add $id etc/skel/ /etc/skel/
buildah copy $id etc/skel/ /root/
buildah run $id adduser worker -D
buildah run $id apk add build-base zstd-dev sbcl curl make git linux-headers cargo openssl perl llvm clang pkg-config
buildah run $id mkdir /store
buildah run $id mkdir /stash
buildah run $id mkdir /usr/share/lisp
buildah run $id mkdir /usr/local/share/lisp
buildah config --volume /store $id
buildah run --net host $id hg clone https://vc.compiler.company/comp/infra
buildah config --workingdir /infra $id 
buildah run --net host $id sh -c 'make worker -j4'
buildah run --net host $id sh -c 'scripts/install-cargo-tools.sh'
buildah run --net host $id sh -c 'make clean'
buildah add $id etc/sbclrc /etc/sbclrc # add this AFTER building sbcl
buildah config --workingdir /stash $id
buildah commit $id ci-worker
