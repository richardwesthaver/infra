#!/usr/bin/env bash
CORE_SRC=${2:-/usr/local/src/core}
FORM="(progn (pushnew #P\"$CORE_SRC\" asdf:*central-registry*) "
FORM+="(ql:quickload :std) "
FORM+=" (ql:quickload \""
FORM+="${1:-bin/skel}"
FORM+="\") (asdf:make \""
FORM+="${1:-bin/skel}"
FORM+="\"))"
sbcl --noinform --non-interactive --eval "$FORM"
