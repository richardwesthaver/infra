#!/bin/sh
# save an sbcl core image
CORE_SRC=${2:-/usr/local/src/core/}
FORM="(progn (pushnew #P\"$CORE_SRC\" asdf:*central-registry*) (pushnew #P\"$CORE_SRC\" ql:*local-project-directories*) (ql:quickload :std) ${3} (save-lisp-and-die \"${1:-std.core}\"))"
sbcl --noinform --non-interactive --eval "$FORM"
