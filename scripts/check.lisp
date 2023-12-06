;;; scripts/check.lisp --- check host features

;; This script runs some basic checks to ensure the host is ready for
;; bootstrapping.

;;; Code:
(defpackage :infra/scripts/check
  (:nicknames :check)
  (:use :cl :std :std/fmt :sb-alien)
  (:export :main
           :*results*
           :check))

(in-package :infra/scripts/check)

(defvar *results* (make-hash-table :size 32 :test 'equal))

(defparameter *library-path* (ld-library-path-list))
(defparameter *exec-path* (exec-path-list))

(defun get-result (k) (gethash k *results*))

(defun push-result (k &optional v) 
  (setf (gethash k *results*) v))

(defmacro check-err (is-warn ctrl name)
  `(if ,is-warn
       (and
         (warn 'simple-warning 
               :format-control ,ctrl
               :format-arguments (list ,name))
         (push-result ,name))
       (error 'simple-program-error 
              :format-control ,ctrl
              :format-arguments (list ,name))))
       
(defun check-for-shared-lib (name &optional warn)
  "Check for a shared library by loading it in the current session with dlopen.

When WARN is non-nil, signal a warning instead of an error."
  (if-let ((lib (ignore-errors (load-shared-object (format nil "lib~a.so" name)))))
    (prog1
        (push-result name lib)
      (unload-shared-object lib))
    (check-err warn "shared library missing: ~x" name)))

(defun check-for-bin (name &optional warn)
  (if-let ((exe (find-exe name)))
    (push-result name exe)
    (check-err warn "executable program missing: ~x" name)))

(defun check-for-src (name)
  (push-result name))

(defun check-hostname () (push-result "hostname" (machine-instance)))

(defun check-user () (push-result "user" (cons (sb-posix:getenv "USER") (user-homedir-pathname))))
  
(defun check-system ()
  (destructuring-bind (lisp version features)
      (my-lisp-implementation)
    (push-result "lisp" (list lisp version features)
    #-sbcl (push-result "lisp" "unsupported")
    #-sb-core-compression (println "WARNING: feature sb-core-compression disabled")
    #-mark-region-gc (println "WARNING: feature mark-region-gc disabled")
)))

(defun check-shell ()
  (push-result "shell" (sb-posix:getenv "SHELL")))

(defun check-display ()
  (push-result "display" (sb-posix:getenv "DISPLAY")))

(defun check-net ()
  (push-result "net"))

(defun check-cpu ()
  (push-result "cpu" (machine-version)))

(defmethod print-object ((object hash-table) stream)
  (format stream "#HOST-FEATURES{~{~{~%(~a . ~a)~}~^ ~}}"
          (loop for k being the hash-keys of *results*
                  using (hash-value v)
                unless (null v) 
                  collect (list k v))))

(defun check (&optional warn)
  "Check the host for required features."

  (setq *library-path* (ld-library-path-list)
        *exec-path* (exec-path-list))

  (debug! (format nil "LD_LIBRARY_PATH: ~A~%" *library-path*))
  (debug! (format nil "PATH: ~A~%" *exec-path*))
  (check-system)
  (check-user)
  (check-net)
  (check-hostname)
  (check-cpu)
  (check-shell)
  (check-display)
  (check-for-bin "sbcl" warn)
  (check-for-bin "rustc" warn)
  (check-for-bin "clang" warn)
  (check-for-bin "gcc" warn)
  (check-for-bin "emacs" warn)
  ;; vcs
  (check-for-bin "hg" warn)
  (check-for-bin "git" warn)
  ;; virt
  (check-for-bin "podman" warn)

  (check-for-src "core")
  ;; core dependencies
  (check-for-shared-lib "rocksdb" warn)
  (check-for-shared-lib "uring" warn)
  (check-for-shared-lib "btrfs" warn)
  (check-for-shared-lib "btrfsutil" warn)
  (check-for-shared-lib "tree-sitter" warn)
  ;; extras
  (check-for-shared-lib "gtk-4" warn)
  (check-for-shared-lib "blake3" warn)
  (check-for-shared-lib "k" warn)
  (check-for-shared-lib "cbqn" warn)
  *results*)

(defmain () (println (check)))
