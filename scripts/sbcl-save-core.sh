#!/bin/sh
# save an sbcl core image
CORE_SRC=${1:-/usr/local/src/core}
FORM="(progn (pushnew #P\"$CORE_SRC\" asdf:*central-registry*) (ql:quickload :std) ${2} (save-lisp-and-die \"${1:-std.core}\"))"
sbcl --noinform --non-interactive --eval "$FORM"
