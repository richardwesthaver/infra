;;; org-graph-db-init.lisp --- Initialize the org-graph-db-directory

;; 

;;; Code:
#-user (ql:quickload :user)
(in-package :user)
(defpkg :org-graph-db-init
  (:use :cl :std :rdb
   :obj/db :obj/query :obj/id :obj/uuid))

(in-package :org-graph-db-init)

(rocksdb:load-rocksdb)

(defvar org-graph-schema nil)

(defvar org-graph)

(defparameter org-graph-db-directory
  (or (probe-file (car (cli:args)))
      #P"~/.stash/org/graph/db"))

(defun init-org-graph-db ()
  (with-db (db (make-rdb "org-graph" (make-rdb-opts)))))
