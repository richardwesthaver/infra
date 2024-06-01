#!/bin/sh
IMG="${1:-.stash/box/vm.releng.raw}"
qemu-system-x86_64 $IMG -m 8G -cpu host --accel kvm
# -chardev socket,path=.stash/qga.sock,server=on,wait=off,id=qga0 \
# -device virtio-serial -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0 \
                   
