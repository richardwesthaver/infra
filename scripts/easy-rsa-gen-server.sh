#!/bin/sh
set -e
cd /etc/easy-rsa
easyrsa init-pki
easyrsa gen-req $HOSTNAME nopass
cp /etc/easy-rsa/pki/private/$HOSTNAME.key /etc/openvpn/server/
# HMAC key with elliptic curve
openvpn --genkey tls-auth /etc/openvpn/server/ta.key
chown openvpn:network /etc/openvpn/server/ta.key
