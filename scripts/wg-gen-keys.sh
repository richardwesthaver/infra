#!/bin/sh
# generate base64-enc keypair in current dir
umask 077
f1=${1:-private.key}
f2=${2:-public.key}
wg genkey | tee $f1 | wg pubkey > $f2
