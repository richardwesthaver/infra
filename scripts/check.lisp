;;; scripts/check.lisp --- check host features

;; This script runs some basic checks to ensure the host is ready for
;; bootstrapping.

;;; Code:
(require 'asdf)
(require 'sb-posix)
(asdf:load-asd #P"~/dev/comp/core/lisp/std/std.asd")
(asdf:load-system :std)

(defpackage :infra/scripts/check
  (:use :cl :std :sb-alien)
  (:export :main
           :*results*))

(in-package :infra/scripts/check)

(defvar *results* (make-hash-table :size 32 :test 'equal))

(defparameter *library-path* (ld-library-path-list))
(defparameter *exec-path* (exec-path-list))

(defun get-result (k) (gethash k *results*))

(defun push-result (k &optional v) 
  (setf (gethash k *results*) v))

(defun check-for-shared-lib (name)
  (if-let ((lib (ignore-errors (load-shared-object (format nil "lib~a.so" name)))))
    (prog1
        (push-result name lib)
      (unload-shared-object lib))
    (push-result name)))

(defun check-for-bin (name)
  (push-result name))

(defun check-for-src (name)
  (push-result name))

(defun check-system ()
  (destructuring-bind (lisp version features)
      (my-lisp-implementation)
    (push-result "lisp" (list lisp version features)
    #-sbcl (push-result "lisp"))))

(defun check-shell ()
  (push-result "shell" (sb-posix:getcwd)))

(defun check-display ()
  (push-result "display"))

(defun check-net ()
  (push-result "net"))

(defun check-cpu ()
  (push-result "cpu"))

(defmethod print-object ((object hash-table) stream)
  (format stream "#HOST-FEATURES{~{~{~%(~a . ~a)~}~^ ~}}"
          (loop for k being the hash-keys of *results*
                  using (hash-value v)
                unless (null v) 
                  collect (list k v))))

(defmain ()
  "Check the host for required features."

  (setq *library-path* (ld-library-path-list)
        *exec-path* (exec-path-list))

  (debug! (format nil "LD_LIBRARY_PATH: ~A~%" *library-path*))
  (debug! (format nil "PATH: ~A~%" *exec-path*))
  (check-system)
  (check-shell)

  (check-for-bin "sbcl")
  (check-for-bin "rustc")
  (check-for-bin "clang")
  (check-for-bin "gcc")
  (check-for-bin "emacs")
  ;; vcs
  (check-for-bin "hg")
  (check-for-bin "git")
  ;; virt
  (check-for-bin "podman")

  (check-for-src "core")
  ;; core dependencies
  (check-for-shared-lib "rocksdb")
  (check-for-shared-lib "uring")
  (check-for-shared-lib "btrfs")
  (check-for-shared-lib "btrfsutil")
  (check-for-shared-lib "tree-sitter")
  ;; extras
  (check-for-shared-lib "sbcl") ;; requires compiling sbcl as shared_lib
  (check-for-shared-lib "gtk-4")
  (check-for-shared-lib "blake3")
  (check-for-shared-lib "k")
  (check-for-shared-lib "cbqn")
  (print *results*)
  *results*)

(main)
