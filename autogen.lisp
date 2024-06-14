;;; autogen.lisp --- Setup the current directory for 

;; sbcl --load autogen.lisp

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

(defparameter *profile* (uiop:read-file-forms
                         (if-let ((profile (sb-posix:getenv "INFRA_PROFILE")))
                                 profile
                                 #P"default.sxp")))
(defparameter *core* sb-ext:*core-pathname*)
(defparameter *host* (uiop:read-file-forms
                      (let ((hcfg (format nil "~a.sxp" (sb-unix:unix-gethostname))))
                        (unless (probe-file hcfg)
                          (print #0$./check.sh$#))
                        hcfg)))

(defun gethost (k) (getf *host* k))
(defun getprofile (k) (getf *profile* k))
(init-skel-vars)
(setq *skel-project* (find-skelfile *default-pathname-defaults* :load t))
(defparameter *host-env* (let ((table (make-hash-table :test 'equal))
                               (keys (list "STASH" "STORE" "DIST" "PACKY_URL" "VC_URL" "INSTALL_PREFIX"
                                           "CC" "AR" "HG" "GIT" "LISP" "RUST" "LD" "SHELL" "DEV" "DEV_HOME"
                                           "DEV_ID" "WORKER" "WORKER_ID" "WORKER_HOME" "CARGO_HOME" "RUSTUP_HOME"
                                           "LISP_HOME" "INFRA_PROFILE")))
                           (dolist (k keys table)
                             (setf (gethash k table) (sb-posix:getenv k)))))
(defun getenv (k) (gethash *host-env* k))

(defun autogen ()
  "Auto-generate the INFRA system."
  (info! "starting autogen.lisp" sb-ext:*core-pathname*)
  (terpri)
  ;; print host, env, profile
  (format t "core: ~A~%" *core*)
  (terpri)
  (println "host:")
  (loop for (k v) on *host* by 'cddr
        do (format t "  ~A = ~A~%" k v))
  (println "env:")
  (loop for k being the hash-key
        using (hash-value v) of *host-env*
        do (format t "  ~A = ~:A~%" k v))
  (println "profile:")
  (loop for (k v) on *profile* by 'cddr
        do (format t "  ~A = ~A~%" k v))
  ;; fresh bootstrap
  (sk-call* *skel-project* :clean :bootstrap))

(defun build-default ()
  (let ((rocksdb-builder (sb-thread:make-thread (lambda () (sk-call* *skel-project* :rocksdb))))
        (sbcl-builder (sb-thread:make-thread (lambda () (sk-call* *skel-project* :sbcl :sbcl-shared))))
        (operator-builder (sb-thread:make-thread (lambda () (sk-call *skel-project* :archlinux :operator))))
        (worker-builder (sb-thread:make-thread (lambda () (sk-call *skel-project* :alpine :worker)))))
    (std/thread:wait-for-threads
     (list rocksdb-builder sbcl-builder operator-builder worker-builder))))

;;; *host*
;; The host profile is generated automatically by 'check.sh'. After running
;; the script you'll have a file HOST.sxp.

;;; *profile*
;; The default profile is defined in 'default.sxp'. You can use that as a base
;; configuration and override it with INFRA_PROFILE

;; (sb-ext:quit)
(unless (probe-file #p".stash")
  (autogen))

(build-default)

(sb-ext:quit)
