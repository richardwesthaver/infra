#!/bin/sh
set -e
cd /root
export EASYRSA=/etc/easy-rsa
export EASYRSA_VARS_FILE=/etc/easy-rsa/vars
easyrsa init-pki
easyrsa build-ca
# now copy /etc/easy-rsa/pki/ca.crt to vpn server /etc/openvpn/server/ca.crt

# run easy-rsa-gen-server.sh

# run easy-rsa-gen-client.sh

# import and sign

# delete temporary reqs

# send signed certs back to client/server

# chown openvpn:network /etc/openvpn/*/*.crt
