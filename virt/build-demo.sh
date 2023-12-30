#!/usr/bin/env bash
id=$(buildah from box-base)
buildah run --net host $id hg clone https://vc.compiler.company/comp/demo /usr/src/demo
buildah run --net host $id /bin/sh -c 'cd /usr/src/infra && make sbcl-install && make rocksdb-install && make ts-langs && make dist/fasl'
buildah run $id cp /usr/src/infra/dist/fasl/* /usr/local/lib/sbcl/
buildah run $id hg clone /usr/src/demo # to /home/$USER
buildah commit $id demo
