#!/bin/sh
IMG="${1:-.stash/box/vm.releng.raw}"
qemu-system-x86_64 -boot order=d -drive file=$IMG,format=raw -m 8G -cpu host -accel kvm
