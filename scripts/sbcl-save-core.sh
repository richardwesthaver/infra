#!/bin/sh
# save an sbcl core image
FORM="(progn (ql:quickload :std) ${2} (save-lisp-and-die \"${1:-std.core}\"))"
sbcl --noinform --non-interactive --eval "$FORM"
