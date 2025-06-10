;;; util.lisp --- Infrastructure Utilities

;; 

;;; Code:
(in-package :sk-user)
(in-readtable :shell)
(use-package '(:cli/tools/term :cli/tools/net :cli/env :pod :box))
;; (use-package :infra/util :sk-user)

;; host checks
(defparameter *host-checks* nil)

(macrolet ((def-check (name &body body)
             `(definline ,(symbolicate "CHECK-" name) ()
                (let ((ret (progn ,@body)))
                  (assert ret (ret) (format nil "check failed: ~A" ',name))
                  (pushnew `(,',name ,ret) *host-checks* :test (lambda (a b) (eql (car a) (car b))))))))
  (def-check shell (sb-posix:getenv "SHELL"))
  (def-check machine 
      (let ((ret (current-machine)))
        (nconc (nreverse ret) (list (num-cpus)))))
  (def-check display (sb-posix:getenv "DISPLAY"))
  (def-check user 
      (list (sb-posix:getenv "USER") 
            (sb-posix:getuid) 
            (sb-posix:getgid) 
            (user-homedir-pathname)))
  (def-check lisp 
      (list 
       (find-exe (string-downcase (lisp-implementation-type)))
       (lisp-implementation-version)))
  (def-check core 
    (when-let ((core (find-exe "core")))
      (cons (find-exe "core")
            (read 
             (process-output 
              (run-program
               core
               '("--eval" "(print (lisp-implementation-version))" "--quit") 
               :output :stream))))))
  (def-check cc (or (sb-posix:getenv "CC") (find-exe "gcc") (find-exe "clang"))))

(definline check-host ()
  (check-shell)
  (check-machine)
  (check-display)
  (check-user)
  (check-lisp)
  (check-cc)
  (check-core)
  *host-checks*)

(definline %script-name () (format nil "ts-~A" (time:format-date-simple)))
(defun script-record (&key (name (%script-name)) log)
  (run-script "-t" (or log (concatenate 'string name ".log")) "-q" name "-c"))
(defun script-replay (&key (name (%script-name)) log)
  (run-scriptreplay "-t" (or log (concatenate 'string name ".log")) name))

;; useradd vc -U -r -s /sbin/nologin -d /home/vc -c "vc user"

;; sudo mkarchiso -v -w /tmp/archiso-tmp -o .stash/box /usr/share/archiso/configs/releng/

;; run_archiso -u -i /path/to/archlinux-yyyy.mm.dd-x86_64.iso

;; get-iso.sh IMG
(defun archiso-name (profile)
  (format nil "~A-~A.iso" profile (string-downcase (substitute #\_ #\- (machine-type)))))

(defun get-archiso (&optional (profile "releng") (output-directory ".stash/box/"))
  (let ((name (archiso-name profile)))
    (req:fetch (format nil "https://packy.compiler.company/box/~A" name) 
               (merge-pathnames name output-directory))))

(defun aws-set-env (key-id access-key &optional (region :us-east-1))
  (values
   (sb-posix:setenv "AWS_ACCESS_KEY_ID" key-id 1)
   (sb-posix:setenv "AWS_SECRET_ACCESS_KEY" access-key 1)
   (sb-posix:setenv "AWS_DEFAULT_REGION" (string-downcase region) 1)))

(defmacro install-quicklisp (init-file
                          &key (home (merge-homedir-pathnames ".stash/quicklisp/"))
                               (dist-version "latest")
                               (client-version "latest")
                               (uri "https://beta.quicklisp.org/quicklisp.lisp"))
  (unless (probe-file init-file)
    (req:fetch uri init-file))
  `(with-sbcl (:non-interactive t :noinform t :quit t)
     (load ,init-file)
     (funcall (find-symbol "INSTALL" :quicklisp-quickstart) :path ,home :dist-version ,dist-version :client-version ,client-version)
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
