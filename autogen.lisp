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
                           profile
                           #P"default.sxp")))
(defparameter *core* sb-ext:*core-pathname*)
(defparameter *host* (uiop:read-file-forms
                      (let ((hcfg (format nil "~a.sxp" (sb-unix:unix-gethostname))))
                        (unless (probe-file hcfg)
                          (print #0$./check.sh$#))
                        hcfg)))
(defparameter *host-env* (let ((table (make-hash-table :test 'equal))
                               (keys (list "STASH" "STORE" "DIST" "PACKY_URL" "VC_URL" "INSTALL_PREFIX"
                                           "CC" "AR" "HG" "GIT" "LISP" "RUST" "LD" "SHELL" "DEV" "DEV_HOME"
                                           "DEV_ID" "WORKER" "WORKER_ID" "WORKER_HOME" "CARGO_HOME" "RUSTUP_HOME"
                                           "LISP_HOME" "INFRA_PROFILE")))
                           (dolist (k keys table)
                             (setf (gethash k table) (sb-posix:getenv k)))))

;;; Utils
(defun gethost (k) (getf *host* k))
(defun getprofile (k) (getf *profile* k))

(defun getenv (k) (gethash *host-env* k))

(defun setenv (k v)
  (sb-posix:setenv k v 1)
  (setf (gethash k *host-env*) v))

;;; Config
(defun init-profile ()
  (let ((stash (getprofile :stash))
        (cc (getprofile :cc)))
    (if-let ((stash (probe-file stash)))
      (setenv "STASH" (namestring stash))
      (error "STASH not found: ~A" stash))
    (if-let ((cc (cli:find-exe cc)))
      (setenv "CC" (namestring cc))
      (error "STASH not found: ~A" cc))))

;;; Build
(defun make-default ()
  (std/thread:wait-for-threads
   (list (sb-thread:make-thread (lambda () (sk-call* *skel-project* :repos)))
         (sb-thread:make-thread (lambda () (sk-call* *skel-project* :packy-repos))))))

(defun make-pods ()
  (std/thread:wait-for-threads
   (list (sb-thread:make-thread (lambda () (sk-call* *skel-project* :archlinux :box)))
         (sb-thread:make-thread (lambda () (sk-call* *skel-project* :alpine :worker))))))

(defun autogen ()
  "Auto-generate the INFRA system."
  (info! "starting autogen")
  (in-readtable :shell)
  (terpri)
  (init-profile)
  (init-skel-vars)
  (setq *skel-project* (find-skelfile *default-pathname-defaults* :load t))
  (unless (probe-file #p".stash")
    (sk-call* *skel-project* :bootstrap))
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
  (make-default))

;;; *host*
;; The host profile is generated automatically by 'check.sh'. After running
;; the script you'll have a file HOST.sxp.

;;; *profile*
;; The default profile is defined in 'default.sxp'. You can use that as a base
;; configuration and override it with INFRA_PROFILE
