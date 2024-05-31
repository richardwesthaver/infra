#!/bin/sh
# build vm.linux.raw
OUT=".stash/box"
qemu-img create -f raw $OUT/vm.releng.raw 32G
qemu-system-x86_64 -cdrom $OUT/releng-*-x86_64.iso -boot order=d -drive file=vm.linux.raw,format=raw -m 8G
# qemu-system-x86_64 vm.linux.cow
