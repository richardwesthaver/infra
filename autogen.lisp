;;; autogen.lisp --- Auto-generate CC Infrastructure

;; This script must be ran with a compliant CC lisp core image from a complian
;; CC lisp compiler. The easiest way to get started is by running the
;; 'bootstrap.sh' script first which will download these for you into the
;; local 'STASH' directory and run this script automatically.

#|
# download pre-compiled binaries and run autogen.lisp
./bootstrap.sh 

# or run manually with local lisp runtime and core
sbcl --core $LISP_HOME/user.core --script autogen.lisp \
--eval "(infra/autogen:autogen)"
|#

;;; Code:
(in-package :std-user)

(defpkg :infra/autogen
  (:use :cl :skel :log :std/named-readtables
        :dat/json :dat/sxp :net/fetch :net/util
        :cli/progress :cli/ansi :cli/ed :cli/prompt
        :cli/shell :std/hash-table :std/alien :std/macs
        :std/fmt)
  (:export :autogen))

(in-package :infra/autogen)
(in-readtable :shell)
;;; Vars
(defvar *all-features*
  (list :default :org :demo :emacs-mini :ts :ts-langs :rust-tools :quicklisp :pod :box :packy))

(defparameter *profile* (uiop:read-file-forms
                         (if-let ((profile (sb-posix:getenv "INFRA_PROFILE")))
                                 (probe-file profile)
                                 (when-let ((default (probe-file "default.sxp")))
                                           (sb-posix:setenv "INFRA_PROFILE" (namestring default) 1)
                                           default))))
(defparameter *host* (uiop:read-file-forms
                      (let ((hcfg (format nil "~a.sxp" (sb-unix:unix-gethostname))))
                        (unless (probe-file hcfg)
                          (print #0$./check.sh$#))
                        hcfg)))
(defparameter *host-env* (let ((table (make-hash-table :test 'equal))
                               (keys (list "STASH" "STORE" "DIST" "PACKY_URL" "VC_URL" "INSTALL_PREFIX"
                                           "CC" "AR" "HG" "GIT" "LISP" "RUSTC" "LD" "SHELL" "DEV" "DEV_HOME"
                                           "DEV_ID" "WORKER" "WORKER_ID" "WORKER_HOME" "CARGO_HOME" "RUSTUP_HOME"
                                           "LISP_HOME" "INFRA_PROFILE" "LOG_LEVEL")))
                           (dolist (k keys table)
                             (setf (gethash k table) (sb-posix:getenv k)))))

;;; Utils
(defun gethost (k) (getf *host* k))
(defun getprofile (k) (getf *profile* k))

(defun getenv (k) (gethash *host-env* k))

(defun setenv (k v)
  (sb-posix:setenv k v 1)
  (setf (gethash k *host-env*) v))

(defmacro setenv* (&rest forms)
  `(progn
     ,@(loop for (k v) on forms by #'cddr while v
             collect `(setenv ,k (or ,v "")))))

(defmacro check-err (is-warn ctrl &rest args)
  `(if ,is-warn
       (warn 'simple-warning 
             :format-control ,ctrl
             :format-arguments (list ,@args))
       (std:simple-program-error
        ,ctrl
        ,@args)))

(defun setenv-exe (k v &optional warn)
  (if-let ((path (cli:find-exe v)))
          (setenv k (namestring path))
          (check-err warn "~A not found: ~A" k v)))

(defun setenv-probe (k v &optional warn)
  (if-let ((path (probe-file v)))
          (setenv k (namestring path))
          (check-err warn "~A not found: ~A" k v)))

(defun check-shared-lib (name &optional warn)
  "Check for a shared library by loading it in the current session with dlopen.
When WARN is non-nil, signal a warning instead of an error."
  (let ((local-lib-name (format nil "/usr/local/lib/lib~a.so" name))
        (sys-lib-name (format nil "/usr/lib/lib~a.so" name)))
    (if-let ((lib (or (ignore-errors (sb-alien:load-shared-object local-lib-name))
                      (ignore-errors (sb-alien:load-shared-object sys-lib-name)))))
            (unwind-protect (format t "found shared lib: ~A~%" lib)
              (sb-alien:unload-shared-object lib))
            (check-err warn "shared library missing in /usr/lib/ or /usr/local/lib/: ~x" name))))

(defun check-exe (name &optional warn)
  "Check for an executable in current $PATH by NAME. When WARN is non-nil, signal
a warning instead of an error."
  (if-let ((bin (cli:find-exe name)))
          (progn (format t "found executable: ~A~%" bin) t)
          (check-err warn "executable missing: ~x" name)))

(defun check-default ()
  (check-shared-lib "rocksdb")
  (check-shared-lib "uring")
  (check-shared-lib "zstd")
  (check-shared-lib "tree-sitter")
  (check-shared-lib "xkbcommon"))

(defun check-org ()
  (check-exe "emacs" t))

(defun check-pod ()
  (check-exe "podman"))

(defun check-box ()
  (check-exe "qemu-system-x86_64"))

(defun check-all ()
  (check-default)
  (check-org)
  (check-pod)
  (check-box))

(defun check-feature (name)
  "Dispatch a host check based on feature NAME."
  (case name
    (:default (check-default))
    (:org (check-org))
    (:pod (check-pod))
    (:box (check-box))
    (:all (check-all))
    (t (warn "unsupported feature: ~A" name))))

(defun getpro-else (k else) (or (getprofile k) else))

;;; Config
(defun init-profile ()
  (info! "initializing profile...")
  (let* ((packy-url (uri:uri (getpro-else :packy-url "https://packy.compiler.company")))
         (vc-url (uri:uri (getpro-else :packy-url "https://vc.compiler.company")))
         (ar (getpro-else :ar "tar"))
         (git (getpro-else :git "git"))
         (hg (getpro-else :hg "hg"))
         (cc (getpro-else :cc "clang"))
         (ld (getpro-else :ld "lld"))
         (install-prefix (getpro-else :install-prefix "/usr/local"))
         (stash (getpro-else :stash ".stash"))
         (store (getpro-else :store (namestring (merge-pathnames "share/store" stash))))
         (dist (getpro-else :dist (namestring (merge-pathnames "dist" store))))
         (lisp (getpro-else :lisp (lisp-implementation-type)))
         (lisp-version (getpro-else :lisp-version (lisp-implementation-version)))
         (log-level (getprofile :log-level))
         (lisp-home (getprofile :lisp-home))
         (quicklisp-home (getprofile :quicklisp-home))
         (rustc (getpro-else :rustc "rustc"))
         (rust-home (getprofile :rust-home))
         (rustup-home (getprofile :rustup-home))
         (cargo-home (getprofile :cargo-home))
         (features (getprofile :features)))
    (setq *log-level* log-level)
    (when (log:trace-p)
      (trace! "env before update:")
      (loop for k being the hash-key
            using (hash-value v) of *host-env*
            do (format t "  ~A = ~A~%" k (or v ""))
            finally (terpri)))
    (setenv-probe "STASH" stash t)
    (setenv-probe "STORE" store t)
    (setenv-probe "DIST" dist t)
    (setenv-probe "INSTALL_PREFIX" install-prefix)
    (setenv-exe "CC" cc)
    (setenv-exe "LD" ld)
    (setenv-exe "AR" ar)
    (setenv-exe "GIT" git)
    (setenv-exe "HG" hg)
    (setenv-exe "RUSTC" rustc t)
    (setenv-exe "LISP" lisp t)
    (setenv*
     "PACKY_URL" (uri:uri-to-string packy-url)
     "VC_URL" (uri:uri-to-string vc-url)
     "LISP_VERSION" lisp-version
     "LISP_HOME" lisp-home
     "QUICKLISP_HOME" quicklisp-home
     "RUST_HOME" rust-home
     "RUSTUP_HOME" rustup-home
     "CARGO_HOME" cargo-home
     "INSTALL_PREFIX" install-prefix
     "LOG_LEVEL" (symbol-name log-level))
    (terpri)
    ;; process features
    (loop for f in features
          do (progn
               (format t "checking host for feature: ~A~%" f)
               (check-feature f)
               (terpri)))))

(defun init-host ()
  )

;;; Build
(defun make-default ()
  (std/thread:wait-for-threads
   (list (sb-thread:make-thread (lambda () (sk-call* *skel-project* :repos)) :name "repos")))
  (std/thread:wait-for-threads
   (list
    (sb-thread:make-thread (lambda () (vc:run-hg-command "clone" (list ".stash/src/core.hg" ".stash/src/core")))
                           :name "core")
    (sb-thread:make-thread (lambda () (vc:run-hg-command "clone" (list ".stash/src/home.hg" ".stash/src/home")))
                           :name "home")
    (sb-thread:make-thread (lambda () (vc:run-hg-command "clone" (list ".stash/src/etc.hg" ".stash/src/etc")))
                           :name "etc"))))

(defun make-pods ()
  (vc:run-hg-command "clone" (list ".stash/src/pod.hg" ".stash/src/pod"))
  (std/thread:wait-for-threads
   (list (sb-thread:make-thread (lambda () (sk-call* *skel-project* :archlinux :box)))
         (sb-thread:make-thread (lambda () (sk-call* *skel-project* :alpine :worker))))))

(defun make-boxes ()
  (vc:run-hg-command "clone" (list ".stash/src/box.hg" ".stash/src/box")))

(defun make-packy ()
  (sk-call* *skel-project* :packy-repos))

(defun make-org ()
  (vc:run-hg-command "clone" (list ".stash/src/org.hg" ".stash/src/org")))

(defun make-demo ()
  (vc:run-hg-command "clone" (list ".stash/src/demo.hg" ".stash/src/demo")))

(defun make-quicklisp ()
  (sk-call *skel-project* :quicklisp))

(defun make-emacs-mini ()
  (sk-run (sk-find-script "install-emacs-mini-pack" *skel-project*)))

(defun make-ts ()
  (sk-call *skel-project* :tree-sitter))

(defun make-ts-langs ()
  (sk-call *skel-project* :tree-sitter-langs))

(defun autogen ()
  (info! (machine-version)
         "starting autogen...")
  (in-readtable :shell)
  (terpri)
  (init-profile)
  (init-host)
  (init-skel-vars)
  (setq *skel-project* (find-skelfile *default-pathname-defaults* :load t))
  (unless (probe-file #p".stash")
    (sk-call* *skel-project* :bootstrap))
  (terpri)
  ;; print post-init info
  (when (log:info-p)
    (log:info! "")
    (format t "lisp: ~A ~A~%"(lisp-implementation-type) (lisp-implementation-version))
    (terpri)
    (format t "core: ~A~%" sb-ext:*core-pathname*)
    (terpri)
    (println "host:")
    (loop for (k v) on *host* by 'cddr
          do (format t "  ~A = ~A~%" k v))
    (terpri)
    (println "profile:")
    (loop for (k v) on *profile* by 'cddr
          do (format t "  ~A = ~A~%" k v))
    (terpri)
    (println "env:")
    (loop for k being the hash-key
          using (hash-value v) of *host-env*
          do (format t "  ~A = ~A~%" k (or v ""))))
  ;; process all features
  (let ((features (getprofile :features)))
    (when (member :all features) (setq features *all-features*))
    (when (member :default features) (make-default))
    (std/thread:wait-for-threads
     (std:flatten
      (list
       (when (member :org features) (sb-thread:make-thread #'make-org :name "org"))
       (when (member :pod features) (sb-thread:make-thread #'make-pods :name "pod"))
       (when (member :quicklisp features) (sb-thread:make-thread #'make-quicklisp :name "quicklisp"))
       (when (member :emacs-mini features) (sb-thread:make-thread #'make-emacs-mini :name "emacs-mini"))
       (when (member :ts features) (sb-thread:make-thread #'make-ts :name "ts"))
       (when (member :ts-langs features) (sb-thread:make-thread #'make-ts-langs :name "ts-langs"))
       (when (member :box features) (sb-thread:make-thread #'make-boxes :name "box"))
       (when (member :packy features) (sb-thread:make-thread #'make-packy :name "packy")))))))
