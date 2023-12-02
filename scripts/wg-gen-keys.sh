#!/bin/sh
# generate base64-enc keypair in current dir
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
