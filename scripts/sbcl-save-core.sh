#!/bin/sh
# save an sbcl core image
FORM="(progn (ql:quickload :std) "
FORM+="${2}"
FORM+=" (save-lisp-and-die \""
FORM+="${1:-std.core}"
FORM+="\"))"
sbcl --noinform --non-interactive --eval "$FORM"
