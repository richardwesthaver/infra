#!/usr/bin/env bash

# these should be spawned as needed by a ci-leader box within a
# dedicated pod named 'ci'.

id=$(buildah from alpine-base)
buildah add $id etc/skel /etc/skel
buildah run $id adduser worker -D
buildah run $id apk add build-base zstd-dev sbcl curl make git linux-headers cargo openssl perl llvm clang
buildah run $id mkdir /store
buildah run $id mkdir /stash
buildah config --volume /store $id
buildah run --net host $id hg clone https://vc.compiler.company/comp/infra
buildah config --workingdir /infra $id 
buildah run --net host $id sh -c 'make worker -j4'
buildah run --net host $id sh -c 'scripts/install-cargo-tools.sh'
buildah run --net host $id sh -c 'make clean'
buildah config --healthcheck bottom
buildah config --workingdir /stash
buildah commit $id ci-worker
