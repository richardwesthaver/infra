#!/usr/local/bin/sbcl --script
;;; scripts/autogen.lisp --- prepare the local environment

;;; Code:
(require 'sb-posix)
(require 'asdf)
(in-package :cl-user)

(format t "Starting comp/infra autogen...~%")

(defvar *scripts* (directory-namestring (or *load-truename* #P"./scripts/")))
(defvar *systems* (list #P"~/quicklisp/dists/quicklisp/software/cl-ppcre-20230618-git/" 
                        #P"~/dev/comp/core/lisp/std/"))

(mapc (lambda (p) (pushnew (sb-ext:native-pathname p) asdf:*central-registry*)) *systems*)

(asdf:load-systems :cl-ppcre :std)
(load (merge-pathnames *scripts* "check.lisp"))
;; check system compatibility
(check:check :warn)

(std:println "DONE.")

(std:println "saving lisp executable to './check'... Bye.")
(sb-ext:save-lisp-and-die "check" :toplevel #'check:main :executable t :compression t)
