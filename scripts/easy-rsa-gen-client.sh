#!/usr/bin/bash
cd /etc/easy-rsa
easyrsa --use-algo=ed --curve=ed25519 --digest=sha512 init-pki
easyrsa gen-req $HOSTNAME nopass
