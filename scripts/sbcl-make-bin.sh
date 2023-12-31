#!/usr/bin/env bash
FORM="(progn (ql:quickload :std) "
FORM+=" (ql:quickload \""
FORM+="${1:-bin/skel}"
FORM+="\") (asdf:make \""
FORM+="${1:-bin/skel}"
FORM+="\"))"
sbcl --noinform --non-interactive --eval "$FORM"
