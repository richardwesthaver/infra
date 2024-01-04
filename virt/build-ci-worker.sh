#!/usr/bin/env bash

# these should be spawned as needed by a ci-leader box within a
# dedicated pod named 'ci'.

id=$(buildah from alpine-base)
buildah add $id etc/skel/ /etc/skel/
buildah run $id adduser worker -D
buildah run $id apk add build-base zstd-dev sbcl curl make git linux-headers cargo openssl-dev perl llvm clang pkgconf
buildah config --volume /store $id
buildah config --volume /stash $id
buildah run $id mkdir /usr/share/lisp
buildah run $id mkdir /usr/local/share/lisp
buildah config --volume /store $id
buildah run --net host $id hg clone https://vc.compiler.company/comp/infra
buildah config --workingdir /infra $id 
buildah run --net host $id sh -c 'make worker -j4'
buildah run --net host $id sh -c 'scripts/install-cargo-tools.sh'
buildah run --net host $id sh -c 'make clean'
buildah copy $id etc/skel/ /root/
buildah copy $id etc/sbclrc /etc/sbclrc
buildah config --workingdir /usr/local/src $id
buildah run --net host $id hg clone https://vc.compiler.company/comp/core
buildah config --workingdir / $id
buildah commit $id ci-worker
