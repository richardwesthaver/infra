;;; bootstrap.lisp --- let 'er rip

;;

;;; Code:
(in-package :std-user)

(defpkg :infra/bootstrap
  (:use :cl :skel :log :std/named-readtables
        :dat/json :dat/sxp :net/fetch :net/util
        :cli/progress :cli/ansi :cli/ed :cli/prompt
        :cli/shell :std/hash-table :std/alien :std/macs
        :std/fmt))
(in-package :infra/bootstrap)
(in-readtable :shell)

(eval-when (:compile-toplevel)
  (defstruct host name cpus mem arch kernel core)
  (defparameter *profile* (read-sxp-file
                           (if-let ((profile (sb-posix:getenv "BUILD_PROFILE")))
                             profile
                             #P"default.sxp")))
  (defparameter *core* sb-ext:*core-pathname*)
  (defparameter *host-config* (read-sxp-file
                               (let ((hcfg (format nil "~a.sxp" (sb-unix:unix-gethostname))))
                                 (unless (probe-file hcfg)
                                   (print #0$./check.sh$#))
                                 hcfg)))
  (defparameter *env* (let ((table (make-hash-table :test 'equal))
                            (keys (list "STASH" "STORE" "DIST" "PACKY_URL" "VC_URL" "INSTALL_PREFIX"
                                        "CC" "AR" "HG" "GIT" "LISP" "RUST" "LD" "SHELL" "DEV" "DEV_HOME"
                                        "DEV_ID" "WORKER" "WORKER_ID" "WORKER_HOME" "CARGO_HOME" "RUSTUP_HOME"
                                        "LISP_HOME")))
                  (dolist (k keys table)
                    (setf (gethash k table) (sb-posix:getenv k))))))

(info! "starting bootstrap.lisp")
(println sb-sys::*machine-version*)
(trace! "env:" (hash-table-alist *env*))

;; build-config
(defun apply-build-config ()
  (setf *log-level* :trace))

;; host-config
