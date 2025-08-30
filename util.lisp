;;; util.lisp --- Infrastructure Utilities

;; 

;;; Code:
(in-package :sk-user)
(in-readtable :shell)
(use-package '(:cli/tools/term :cli/tools/net :cli/env :pod :box))

;; host checks
(defparameter *host-checks* nil)

(macrolet ((def-check (name &body body)
             `(definline ,(symbolicate "CHECK-" name) ()
                (let ((ret (progn ,@body)))
                  (assert ret (ret) (format nil "check failed: ~A" ',name))
                  (pushnew `(,',name ,ret) *host-checks* :test (lambda (a b) (eql (car a) (car b))))))))
  (def-check shell (sb-posix:getenv "SHELL"))
  (def-check term (sb-posix:getenv "TERM"))
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
  (check-term)
  (check-display)
  (check-machine)
  (check-user)
  (check-lisp)
  (check-cc)
  (check-core)
  *host-checks*)

;;; Dependency
(defun dist-dependency (name &optional (packy "/opt/store/packy/") (arch "x86_64-unknown-linux-gnu"))
  "Distribute the dependency NAME."
  (move-file (merge-pathnames (format nil "~A.tar.zst" name) ".stash/")
             (merge-pathnames (format nil "dist/~A/~A.tar.zst" arch name) packy)))

(defun get-dependency-pack (name &optional (arch "x86_64-unknown-linux-gnu"))
  "Install the dependency pack NAME from the remote
packy (packy.compiler.company)."
  (let* ((ntar (format nil "~A.tar" name))
         (n (format nil "~A.zst" ntar)))
    (req:fetch (uri:merge-uris n (uri:merge-uris (format nil "dist/~A" arch) skel/packy:*packy-url*))
               (merge-pathnames name ".stash/tmp/"))))

;;; Utils
(definline %script-name () (format nil "ts-~A" (time:format-date-simple)))
(defun script-record (&key (name (%script-name)) log)
  (run-script "-t" (or log (concatenate 'string name ".log")) "-q" name "-c"))
(defun script-replay (&key (name (%script-name)) log)
  (run-scriptreplay "-t" (or log (concatenate 'string name ".log")) name))

#|
(box/archiso::mkarchiso 
 "/usr/share/archiso/configs/releng" 
 :verbose t :work-dir "/tmp/archiso-tmp" :out-dir ".stash/box")

(box/archiso:run-archiso "/path/to/archlinux-yyyy.mm.dd-x86_64.iso")
|#

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
;; (defmethod skel/packy:install-package ((self infra-package) &key))

;; make-windows-iso
;; (defun make-windows-iso ())

;; qemu-system-x86_64 -cdrom win11-x86_64.iso -hda vm.win11.raw -boot d -accel kvm -m 8G -usbdevice tablet -cpu host -drive file=win11-virtio.iso

(defun run-vm (img &optional (mem "8G"))
  (run-qemu img "--enable-kvm" "-m" mem "-cpu" "host"))

(defun qemu-ifup (intf switch &optional (user (sb-posix:getenv "USER")))
  (run-ip "tuntap" "add" intf "mode" "tap" "user" user)
  (ip-link-up intf)
  (sleep 0.5)
  (run-ip "link" "set" intf "master" switch))

(defun qemu-build-vm (out &optional (size "32G") (mem "8G"))
  (let ((img (namestring out)))
    (run-qemu-img "create" "-f" "raw" img size)
    (run-qemu "-cdrom" img "-boot" "order=d" (format nil "file=~A,format=raw" img) "-m" mem "-cpu" "host")))

;; dist PACKAGE (SOURCE REPO BINARY DOCS)

(defun git-vendor-pull (name domain 
                        &key (path ".stash/src/") 
                             (repo (format nil 
                                           "ssh://git@vc.compiler.company/packy/~A"
                                           name)))
  (ensure-directories-exist path)
  (let ((out (merge-pathnames name path))
        (remote (format nil "https://~A/~A" domain name)))
    (vc-clone out repo)
    (with-repo (r :path out :type :git)
      (vc-pull r remote)
      (vc-push r))))

(defun init-vc-bundles (&optional (dir #p"/usr/local/src/") delete)
  (with-directory dir
    (loop for i in (directory "*.hg")
          with path = (pathname-name i)
          do (with-repo (r :path path :init t)
               (log:info! "unbundling ~A to ~A" i path)
               (vc-unbundle r i)
               (when delete (delete-file i))))))

;; build PACKAGE
(defun random-mac () (format nil "DE:AD:BE:EF:~2,'0x:~2,'0x" (random 255) (random 255)))
  
(defun build-emacs (&key (src ".stash/src/emacs")
                         prefix
                         (with-mailutils t)
                         (with-x-toolkit "lucid")
                         (with-imagemagick t)
                         without-x
                         without-all
                         (without-pop t)
                         (with-tree-sitter t)
                         (without-sound t)
                         (enable-link-time-optimization t)
                         (with-modules t)
                         (disable-gc-mark-trace t))
  (with-directory (probe-directory src)
    (sb-ext:run-program "/bin/sh" '("./autogen.sh"))
    (sb-ext:run-program 
     "/bin/sh"
     `("./configure"
       ,@(when with-mailutils '("--with-mailutils"))
       ,@(when without-x '("--without-x"))
       ,@(when with-imagemagick '("--with-imagemagick"))
       ,@(when with-x-toolkit `(,(format nil "--with-x-toolkit=~A" with-x-toolkit)))
       ,@(when without-pop '("--without-pop"))
       ,@(when with-tree-sitter '("--with-tree-sitter"))
       ,@(when without-sound '("--without-sound"))
       ,@(when without-all '("--without-all"))
       ,@(when enable-link-time-optimization '("--enable-link-time-optimization"))
       ,@(when with-modules '("--with-modules"))
       ,@(when disable-gc-mark-trace '("--disable-gc-mark-trace"))
       ,@(when prefix (format nil "--prefix=~A" prefix))))
    (sb-posix:setenv "NATIVE_FULL_AOT" "1" 1)
    (sb-ext:run-program (find-exe "make") `(,(format nil "-j~A" (num-cpus))) :output t)))
