#!/bin/sh

# build vm.linux.cow

# sudo pacman -S virt-manager virt-viewer qemu qemu-arch-extra 
# edk2-ovmf vde2 ebtables dnsmasq bridge-utils openbsd-netcat libguestfs

# systemctl enable libvirtd.service
# systemctl start libvirtd.service


## intel nested virt
# sudo modprobe -r kvm_intel
# sudo modprobe kvm_intel nested=1
# echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.conf

# systool -m kvm_intel -v | grep nested
# cat /sys/module/kvm_intel/parameters/nested

OUT=".stash"
qemu-img create -f qcow2 $OUT/vm.linux.cow -o backing_file=vm.linux.raw,backing_fmt=raw,nocow=on
# qemu-system-x86_64 vm.linux.cow
