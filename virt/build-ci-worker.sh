#!/usr/bin/env bash

# these should be spawned as needed by a ci-leader box within a
# dedicated pod named 'ci'.

id=$(buildah from alpine-base)
buildah add $id etc/skel /etc/skel
buildah run $id adduser alik -D -k /etc/skel
buildah run $id adduser demon -D -k /etc/skel
buildah run $id apk add build-base zstd-dev sbcl curl make git linux-headers cargo openssl perl llvm
buildah config --workingdir /home/demon $id
buildah config --volume /mnt/y $id
buildah run --net host $id hg clone https://vc.compiler.company/comp/infra
buildah run --net host $id sh -c 'make -C infra rocksdb-install'
buildah run --net host $id sh -c 'make -C infra sbcl-install'
buildah run --net host $id sh -c 'make -C infra ts-langs-install'
buildah run --net host $id sh -c 'make -C infra dist/lisp/fasl'
buildah run --net host $id sh -c 'mv infra/dist/lisp/fasl/* /usr/local/lib/sbcl/'
buildah run --net host $id sh -c './infra/scripts/install-cargo-tools.sh'
buildah run --net host $id sh -c 'make -C infra clean'
buildah config --entrypoint '["/usr/local/bin/sbcl", "--core", "/usr/local/lib/sbcl/prelude.fasl"]' $id
buildah commit $id ci-worker
