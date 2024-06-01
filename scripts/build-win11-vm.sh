#!/bin/sh
# build vm.linux.raw
OUT=".stash/box"
qemu-img create -f raw $OUT/vm.win11.raw 64G
cd $OUT
curl -O "https://packy.compiler.company/box/win11-virtio.iso"
sudo qemu-system-x86_64 -cdrom win11-x86_64.iso -hda vm.win11.raw -boot d -accel kvm -m 8G -usbdevice tablet -cpu host -drive file=win11-virtio.iso
