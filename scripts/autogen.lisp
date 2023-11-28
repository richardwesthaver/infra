;;; scripts/autogen.lisp --- prepare the local environment

;;; Code:
(in-package :cl-user)
(use-package :std)

(defmain ()
  "Prepare the local environment for bootstrapping a complete system."
  (format t "Starting scripts/autogen.lisp...~%"))
