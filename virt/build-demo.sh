#!/usr/bin/env bash
id=$(buildah from alpine-base)
buildah config --workingdir /home/demo $id
buildah config -l=demo $id
buildah run $id adduser demo
buildah copy $id dist/sbcl /home/demo/sbcl
buildah copy $id dist/fasl/ /home/demo/fasl
buildah copy $id dist/rocksdb/librocksdb.so /usr/local/lib/
# buildah copy $id dist/tree-sitter/grammar/* /usr/local/share/tree-sitter/
# cleanup
# buildah config --entrypoint 
buildah commit $id demo
