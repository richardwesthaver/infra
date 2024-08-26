;;; org-graph-db-init.lisp --- Initialize the org-graph-db-directory

;; 

;;; Code:
#-user (ql:quickload :user)
(in-package :user)
(unless (find-package :org-graph-db)
  (defpkg :org-graph-db
    (:use :cl :std :rdb
     :obj/db :obj/query :obj/id :obj/uuid)))

(in-package :org-graph-db)

(rocksdb:load-rocksdb)

(defun make-org-graph-schema ()
  (make-schema
   (make-field :name "file" :type 'string)
   (make-field :name "title" :type 'string)
   (make-field :name "hash" :type 'octet-vector)
   (make-field :name "atime" :type 'octet-vector)
   (make-field :name "mtime" :type 'octet-vector)
   (make-field :name "node" :type 'octet-vector)
   (make-field :name "edge" :type 'octet-vector)
   (make-field :name "node-tags" :type 'string)
   (make-field :name "node-links" :type 'string)
   (make-field :name "node-properties" :type 'string)
   (make-field :name "node-priority" :type 'string)
   (make-field :name "node-schedule" :type 'string)
   (make-field :name "node-file" :type 'string)
   (make-field :name "node-pos" :type 'octet-vector)
   (make-field :name "node-state" :type 'string)))

(defparameter *org-graph-schema* (make-org-graph-schema))

(defvar *org-graph-db* nil)

(defparameter *org-graph-db-directory*
  (or (probe-file (car (cli:args)))
      (merge-pathnames ".stash/org/graph/db/" (user-homedir-pathname))))

(defun make-org-graph-db ()
  (create-db (namestring *org-graph-db-directory*)
             :opts (default-rdb-opts)))

(define-condition org-id-locations-out-of-sync (simple-error) ())

(defvar *emacs-org-id-locations-file* (merge-pathnames ".emacs.d/.org-id-locations" (user-homedir-pathname)))

(defun make-org-id-locations (&optional (file *emacs-org-id-locations-file*))
  (let ((tbl (make-hash-table :test 'equal)))
    (with-open-file (file file)
      (dolist (entry (read file))
        (if-let ((file (probe-file (car entry))))
          (setf (gethash (namestring file) tbl) (cdr entry))
          (signal 'org-id-locations-out-of-sync :format-control "~A" :format-arguments (list entry)))))
    tbl))

(defvar *org-graph-id-locations* (make-org-id-locations))

(defun insert-org-files ()
  (log:info! "inserting org files")
  (open-cf *org-graph-db* "file")
  (maphash (lambda (k v) (insert-key *org-graph-db* k
                                     (apply 'concatenate 'string v)
                                     :cf "file"))
           *org-graph-id-locations*)
  (flush-db *org-graph-db*))

(defun insert-org-nodes ()
  (log:info! "inserting org nodes")
  (open-cf *org-graph-db* "node")
  (dolist (v (hash-table-values *org-graph-id-locations*))
    (dolist (id v)
      (insert-key *org-graph-db* id "0" :cf "node"))))

(defun close-org-graph-db ()
  (when (db-open-p *org-graph-db*)
    (close-db *org-graph-db*)))        

(defun init-org-graph-db ()
  (ensure-directories-exist (make-pathname :directory (butlast (pathname-directory *org-graph-db-directory*))) :verbose t)
  (with-db (db (load-schema (make-org-graph-db) *org-graph-schema*))
    (open-db db)
    (open-cfs db)
    (setq *org-graph-db* db)
    ;; (open-cfs db)
    (insert-org-files)
    (insert-org-nodes)
    (log:info! "created org-graph-db" db *org-graph-db-directory* *org-graph-schema*)))

(defun open-org-graph-db ()
  (unless (probe-file *org-graph-db-directory*)
    (init-org-graph-db))
  (if (db-open-p *org-graph-db*)
      *org-graph-db*
      (open-db (or *org-graph-db* (make-org-graph-db)))))

(defun destroy-org-graph-db (&optional force)
  (when (probe-file *org-graph-db-directory*)
    (unwind-protect
         (with-db (db (or *org-graph-db* (make-org-graph-db)))
           (shutdown-db db)
           (destroy-db db)
           (log:info! "destroyed org-graph-db" db *org-graph-db-directory*))
      (when force
        (sb-ext:delete-directory *org-graph-db-directory* :recursive t)
        (setq *org-graph-db* nil)))))
