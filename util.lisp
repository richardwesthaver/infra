;;; util.lisp --- Infrastructure Utilities

;; 

;;; Code:
(defpkg :infra/util 
  (:use :cl :std :cli/tools/term 
   :cli/tools/net :cli/env :pod :box
   :cli/tools/sbcl)
  (:export :*host-checks*
   :check-host :install-quicklisp))
  
(in-package :infra/util)

;; host checks
(defparameter *host-checks* (make-hash-table))

(macrolet ((def-check (name &body body)
             `(definline ,(symbolicate "CHECK-" name) ()
                (let ((ret (progn ,@body)))
                  (assert ret (ret) (format nil "check failed: ~A" ',name))
                  (setf (gethash ',name *host-checks*) ret)))))
  (def-check shell (sb-posix:getenv "SHELL"))
  (def-check cpu (machine-version))
  (def-check display (sb-posix:getenv "DISPLAY"))
  (def-check hostname (machine-instance))
  (def-check user (cons (sb-posix:getenv "USER") (user-homedir-pathname)))
  (def-check lisp (cons (lisp-implementation-type) (lisp-implementation-version)))
  (def-check cc (or (sb-posix:getenv "CC") (find-exe "gcc") (find-exe "clang"))))

(definline check-host ()
  (check-shell)
  (check-cpu)
  (check-display)
  (check-hostname)
  (check-user)
  (check-lisp)
  (check-cc))

(definline %script-name () (format nil "ts-~A" (time:format-date-simple)))
(defun script-record (&key (name (%script-name)) log)
  (run-script "-t" (or log (concatenate 'string name ".log")) "-q" name "-c"))
(defun script-replay (&key (name (%script-name)) log)
  (run-scriptreplay "-t" (or log (concatenate 'string name ".log")) name))

;; useradd vc -U -r -s /sbin/nologin -d /home/vc -c "vc user"

;; sudo mkarchiso -v -w /tmp/archiso-tmp -o .stash/box /usr/share/archiso/configs/releng/

;; run_archiso -u -i /path/to/archlinux-yyyy.mm.dd-x86_64.iso

;; get-iso.sh IMG

(defmacro install-quicklisp (init-file
                          &key (home (merge-homedir-pathnames ".stash/quicklisp/"))
                               (dist-version "latest")
                               (client-version "latest"))
  `(with-sbcl (:non-interactive t :noinform t :quit t)
    (load ,init-file)
    (funcall (find-symbol* 'install :quicklisp-quickstart) :path ,home :dist-version ,dist-version :client-version ,client-version)
    (ql-dist:install-dist "http://dist.ultralisp.org" :prompt nil)))

;; install-pack (app/packy)

;; make-windows-iso
;; (defun make-windows-iso ())

;; qemu-system-x86_64 -cdrom win11-x86_64.iso -hda vm.win11.raw -boot d -accel kvm -m 8G -usbdevice tablet -cpu host -drive file=win11-virtio.iso

;; dist PACKAGE utils

;; build PACKAGE

(defun random-mac () (format nil "DE:AD:BE:EF:~2,'0x:~2,'0x" (random 255) (random 255)))
  
(defun build-emacs (&key (src ".stash/src/emacs/")
                         (with-mailutils t)
                         (with-imagemagick t)
                         (without-pop t)
                         (with-tree-sitter t)
                         (without-sound t)
                         (enable-link-time-optimization t)
                         (with-modules t)
                         (disable-gc-mark-trace t))
  (with-directory src
    (sb-ext:run-program 
     "/bin/sh"
     `(,@(when with-mailutils '("--with-mailutils"))
       ,@(when with-imagemagick '("--with-imagemagick"))
       ,@(when without-pop '("--without-pop"))
       ,@(when with-tree-sitter '("--with-tree-sitter"))
       ,@(when without-sound '("--without-sound"))
       ,@(when enable-link-time-optimization '("--enable-link-time-optimization"))
       ,@(when with-modules '("--with-modules"))
       ,@(when disable-gc-mark-trace '("--disable-gc-mark-trace"))))))
                        
