#!/bin/sh
# build vm.linux.raw
OUT=".stash/box"
qemu-img create -f raw $OUT/vm.releng.raw 32G
qemu-system-x86_64 -enable-kvm -cdrom $OUT/releng-x86_64.iso -boot order=d -drive file=$OUT/vm.releng.raw,format=raw -m 8G -cpu host
