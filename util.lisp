;;; util.lisp --- Infrastructure Utilities

;; 

;;; Code:
(defpkg :infra/util
  (:use :cl :std :cli/tools/term :cli/tools/net))
(in-package :infra/util)

(definline %script-name () (format nil "ts-~A" (time:format-date-simple)))
(defun script-record (&key (name (%script-name)) log)
  (run-script "-t" (or log (concatenate 'string name ".log")) "-q" name "-c"))
(defun script-replay (&key (name (%script-name)) log)
  (run-scriptreplay "-t" (or log (concatenate 'string name ".log")) name))

;; useradd vc -U -r -s /sbin/nologin -d /home/vc -c "vc user"

;; pacman -Sy archlinux-keyring && pacman -Su

;; sudo mkarchiso -v -w /tmp/archiso-tmp -o .stash/box /usr/share/archiso/configs/releng/

;; run_archiso -u -i /path/to/archlinux-yyyy.mm.dd-x86_64.iso

;; get-iso.sh IMG

;; podman system service --time=0 unix:///run/user/$UID/podman.sock # tcp://localhost:4282

;; quicklisp-install

;; tscript/tscriptr (typescript)

;; (cli/tools/net:wg-generate-keys)

;; install-pack (app/packy)

;; make-windows-iso 
#| wget "https://software.download.prss.microsoft.com/dbazure/Win11_23H2_English_x64v2.iso" -O $iso_name
dd if=$iso_name of=$device |#
;; qemu-system-x86_64 -cdrom win11-x86_64.iso -hda vm.win11.raw -boot d -accel kvm -m 8G -usbdevice tablet -cpu host -drive file=win11-virtio.iso

;; easyrsa gen-ca/client/server (cli/tools/net)

;; dist PACKAGE utils

;; build PACKAGE

;; podman machine ssh 'sudo rpm-ostree upgrade --check'

;; printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256))
