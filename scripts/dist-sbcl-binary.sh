#!/bin/sh
set -e
# binary dist
cd .stash/src/ && \
tar -cf sbcl.tar sbcl/output/sbcl.core sbcl/src/runtime/sbcl sbcl/output/prefix.def \
    sbcl/src/runtime/sbcl.mk \
    `grep '^LIBSBCL=' sbcl/src/runtime/sbcl.mk | cut -d= -f2- | while read lib; do echo sbcl/src/runtime/$lib; done` \
    sbcl/BUGS sbcl/COPYING sbcl/CREDITS sbcl/INSTALL sbcl/NEWS sbcl/README \
    sbcl/install.sh sbcl/find-gnumake.sh sbcl/sbcl-pwd.sh sbcl/run-sbcl.sh \
    sbcl/doc/sbcl.1 \
    sbcl/pubring.pgp \
    sbcl/contrib/asdf-module.mk \
    `for contrib in $(cd sbcl/contrib && echo *); do
         src_dir=sbcl/contrib/$contrib
         if test -d $src_dir && test -f sbcl/obj/sbcl-home/contrib/$contrib.fasl; then
             echo $src_dir/Makefile
         fi
     done` \
    sbcl/obj/sbcl-home && \
zstd sbcl.tar && \
rm sbcl.tar && \
mv sbcl.tar.zst ../
