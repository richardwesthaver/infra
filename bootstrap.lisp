;;; bootstrap.lisp --- let 'er rip

;;

;;; Code:
(in-package :std-user)

(defpkg :infra/bootstrap
  (:use :cl :skel :log :std/named-readtables
        :dat/json :dat/sxp :net/fetch :net/util
        :cli/progress :cli/ansi :cli/ed :cli/prompt
        :cli/shell :std/hash-table :std/alien))
(in-package :infra/bootstrap)
(in-readtable :shell)
(eval-when (:compile-toplevel)
  (defstruct host name cpus mem os kernel core)
  (defparameter *config-file* #P"config.sxp")
  (defparameter *build-config* (read-sxp-file *config-file*))
  (defparameter *host-config* (make-host :name (sb-unix:unix-gethostname) :cpus (num-cpus) :mem #+nil (mem-total) 15815828
                                   :os "archlinux" :kernel "linux" :core sb-ext:*core-pathname*))
  (defparameter *env* (let ((table (make-hash-table :test 'equal))
                      (keys (list "CC" "AR" "STASH" "STORE" "DIST" "PACKY_URL" "VC_URL" "PREFIX")))
                  (dolist (k keys table)
                    (setf (gethash k table) (sb-posix:getenv k))))))

(info! "starting bootstrap.lisp")
(debug! "host:" sb-sys::*machine-version*)
(trace! "env:" (hash-table-alist *env*))

;; build-config
(defun apply-build-config ()
  (setf *log-level* :trace))

;; host-config
