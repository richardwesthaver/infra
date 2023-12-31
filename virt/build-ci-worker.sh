#!/usr/bin/env bash

# these should be spawned as needed by a ci-leader box within a
# dedicated pod named 'ci'.

id=$(buildah from alpine-base)
buildah run $id adduser alik -D
buildah run $id adduser demon -D
buildah run $id apk add zstd-dev sbcl curl make rust git linux-headers
buildah config --workingdir /home/demon $id
buildah config -l=demo $id
buildah run --net host $id hg clone https://vc.compiler.company/comp/core
buildah run --net host $id hg clone https://vc.compiler.company/comp/infra
buildah run --net host $id sh -c 'cd infra && make sbcl-install'
# buildah config --entrypoint 
buildah commit $id ci-worker
