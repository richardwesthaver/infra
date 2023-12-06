#!/bin/sh

# eval lisp code with sbcl
LISP=sbcl
args=""
FILE="${1}"
[[ -z "$FILE" ]] && : || args="--script $FILE "
FORM=${2}
[[ -z "$FORM" ]] && : || args="--eval $FORM "
$LISP $args --eval "(quit)"
