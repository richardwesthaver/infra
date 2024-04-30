;;; deploy.lisp --- yeeting blobs across the yard

;;

;;; Code:
(in-package :std-user)

(defpkg :infra/deploy
  (:use :cl :skel :packy :dat/json))

(in-package :infra/deploy)
