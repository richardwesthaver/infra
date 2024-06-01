#!/bin/sh
IMG="${1}"
qemu-system-x86_64 $IMG -enable-kvm -m 8G -cpu host
