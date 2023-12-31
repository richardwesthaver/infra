#!/usr/bin/env bash

# these should be spawned as needed by a ci-leader box within a
# dedicated pod named 'ci'.

id=$(buildah from alpine-base)
buildah copy $id etc/skel /etc/skel
buildah run $id adduser alik -D
buildah run $id adduser demon -D -k /etc/skel
buildah run $id apk add build-base zstd-dev sbcl curl make git linux-headers cargo openssl
buildah config --workingdir /home/demon $id
buildah config -l=demo $id
buildah run --net host $id hg clone https://vc.compiler.company/comp/core
buildah run --net host $id hg clone https://vc.compiler.company/comp/infra
buildah run --net host $id sh -c 'cd infra && make rocksdb-install'
buildah run --net host $id sh -c 'cd infra && make sbcl-install'
buildah run --net host $id sh -c 'cd infra && make ts-langs'
buildah run --net host $id sh -c 'curl -o /tmp/quicklisp.lisp -O https://beta.quicklisp.org/quicklisp.lisp'
buildah run --net host $id sh -c 'sbcl --load /tmp/quicklisp.lisp --eval (quicklisp-quickstart:install)'
buildah run --net host $id sh -c 'cd infra && make dist/fasl'
buildah run --net host $id sh -c 'mv infra/dist/fasl/* /usr/local/lib/sbcl/'
buildah run --net host $id sh -c './infra/scripts/install-cargo-tools.sh'
buildah run --net host $id sh -c 'cd infra && make clean'
buildah config --entrypoint '["sbcl", "--core", "/usr/local/lib/sbcl/prelude.fasl"]' $id
buildah commit $id ci-worker
