#!/bin/sh
# build vm.linux.raw
OUT=".stash/box"
qemu-img create -f raw $OUT/vm.baseline.raw 32G
qemu-system-x86_64 -cdrom $OUT/baseline-x86_64.iso -boot order=d -drive file=$OUT/vm.baseline.raw,format=raw -m 8G
# qemu-system-x86_64 vm.linux.cow
