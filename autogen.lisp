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

(defmacro check-err (is-warn ctrl name)
  `(if ,is-warn
       (warn 'simple-warning 
             :format-control ,ctrl
             :format-arguments (list ,name))
       (error 'simple-program-error 
              :format-control ,ctrl
              :format-arguments (list ,name))))

(defun check-shared-lib (name &optional warn)
  "Check for a shared library by loading it in the current session with dlopen.
When WARN is non-nil, signal a warning instead of an error."
  (let ((lib-name (format nil "lib~a.so" name)))
    (if-let ((lib (ignore-errors (sb-alien:load-shared-object lib-name))))
      (unwind-protect t
        (sb-alien:unload-shared-object lib))
      (check-err warn "shared library missing: ~x" name))))

(defun getpro-else (k else) (or (getprofile k) else))

;;; Config
(defun init-profile ()
  (info! "initializing profile...")
  (let* ((cc (getpro-else :cc "clang"))
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
    (if-let ((stash (probe-file stash)))
      (setenv "STASH" (namestring stash))
      (error "STASH not found: ~A" stash))
    (if-let ((cc (cli:find-exe cc)))
      (setenv "CC" (namestring cc))
      (error "CC not found: ~A" cc))
    (setenv*
     "LD" ld
     "LISP" lisp
     "LISP_VERSION" lisp-version
     "LISP_HOME" lisp-home
     "QUICKLISP_HOME" quicklisp-home
     "RUSTC" rustc
     "RUST_HOME" rust-home
     "RUSTUP_HOME" rustup-home
     "CARGO_HOME" cargo-home
     "INSTALL_PREFIX" install-prefix
     "STORE" store
     "DIST" dist
     "LOG_LEVEL" (symbol-name log-level))
    (setq *log-level* log-level)
    ;; process features
    (loop for f in features
          do (progn
               (format t "checking host for feature dependencies: ~A~%" f)))))

(defun init-host ()
  )

;;; Build
(defun make-default ()
  (std/thread:wait-for-threads
   (list (sb-thread:make-thread (lambda () (sk-call* *skel-project* :repos)))))
  (vc:run-hg-command "clone" (list ".stash/src/core.hg" ".stash/src/core"))
  (vc:run-hg-command "clone" (list ".stash/src/home.hg" ".stash/src/home"))
  (vc:run-hg-command "clone" (list ".stash/src/etc.hg" ".stash/src/etc")))

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
  ;; print post-init info
  (format t "lisp: ~A ~A~%"(lisp-implementation-type) (lisp-implementation-version))
  (format t "core: ~A~%" sb-ext:*core-pathname*)
  (terpri)
  (println "host:")
  (loop for (k v) on *host* by 'cddr
        do (format t "  ~A = ~A~%" k v))
  (println "profile:")
  (loop for (k v) on *profile* by 'cddr
        do (format t "  ~A = ~A~%" k v))
  (println "env:")
  (loop for k being the hash-key
        using (hash-value v) of *host-env*
        do (format t "  ~A = ~A~%" k (or v "")))
  (let ((features (getprofile :features)))
    (std/thread:wait-for-threads
     (std:flatten
      (list
       (when (member :default features) (sb-thread:make-thread 'make-default :name "default"))
       (when (member :pod features) (sb-thread:make-thread 'make-pods :name "pod"))
       (when (member :box features) (sb-thread:make-thread 'make-boxes :name "box"))
       (when (member :org features) (sb-thread:make-thread 'make-pods :name "org"))
       (when (member :packy features) (sb-thread:make-thread 'make-packy :name "packy")))))))
