#!/usr/bin/env bash
DIST=dist
id=$(buildah from alpine-base)
buildah run $id adduser demo
buildah run $id addgroup demo
buildah config --workingdir /home/demo --user demo -l=demo
buildah copy $id dist/sbcl
buildah copy $id dist/fasl/* sbcl
buildah copy $id dist/rocksdb/include/* /usr/local/include/
buildah copy $id dist/rocksdb/librocksdb.so* /usr/local/lib/
# buildah copy $id dist/tree-sitter/grammar/* /usr/local/share/tree-sitter/
buildah run --net host $id /bin/sh -c 'cd infra && make sbcl-install && make rocksdb-install && make ts-langs && make dist/fasl'
buildah run $id /bin/sh -c 'cp infra/dist/fasl/* /usr/local/lib/sbcl/'
# cleanup
buildah config --entrypoint 
buildah commit $id demo
