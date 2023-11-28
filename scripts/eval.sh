#!/bin/sh

# eval lisp code
LISP="/usr/bin/sbcl"
args=""
FILE="${1}"
[[ -z "$FILE" ]] && : || args="--script $FILE "
FORM=${2}
[[ -z "$FORM" ]] && : || args="--eval $FORM "
$LISP $args --eval "(quit)"
