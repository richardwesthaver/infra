;;; org-graph-db-init.lisp --- Initialize the org-graph-db-directory

;; 

;;; Code:
#-user (ql:quickload :user)
(in-package :user)
(unless (find-package :org-graph-db)
  (defpkg :org-graph-db
    (:use :cl :std :rdb :cli :seq
     :db :query :id :uuid :q :schema)))

(in-package :org-graph-db)

(load-database-backend :rdb)

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

(defparameter *org-graph-db-directory*
  (or (probe-file (car (cli:args)))
      (merge-pathnames ".stash/org/graph/db/" (user-homedir-pathname))))

(defun make-org-graph-db ()
  (load-schema
   (make-db :rdb :name (namestring *org-graph-db-directory*)
                 :opts (default-rdb-opts))
   *org-graph-schema*))

(defvar *org-graph-db* (make-org-graph-db))

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
  ;; (open-cfs *org-graph-db* "file")
  (maphash (lambda (k v) (insert-key *org-graph-db* k
                                     (apply 'concatenate 'string v)
                                     :column "file"))
           *org-graph-id-locations*))

(defun insert-org-nodes ()
  (log:info! "inserting org nodes")
  ;; (open-cfs *org-graph-db* "node")
  (dolist (v (hash-table-values *org-graph-id-locations*))
    (dolist (id v)
      (insert-key *org-graph-db*
                  (handler-case (uuid-to-octet-vector (obj/uuid:make-uuid-from-string id))
                    (simple-error () id))
                  #(0 1 2 3)
                  :column "node")))
  (flush-db *org-graph-db*))

;; (loop with i = 0
;; while (iter-valid-p it)
;; do (log:info! (iter-key it) (iter-val it))
;; do (iter-next it)
;; do (print (incf i))))

(defun close-org-graph-db ()
  (when (db-open-p *org-graph-db*)
    (shutdown-db *org-graph-db*)))

(defun init-org-graph-db ()
  (ensure-directories-exist
   (make-pathname :directory (butlast (pathname-directory *org-graph-db-directory*)))
   :verbose t)
  (with-db (db :open t :close nil :db *org-graph-db*)
    (create-columns db)
    (insert-org-files)
    (insert-org-nodes)
    (log:info! "created org-graph-db" *org-graph-db* *org-graph-db-directory* *org-graph-schema*)))

(defun open-org-graph-db ()
  (unless (probe-file *org-graph-db-directory*)
    (init-org-graph-db))
  (if (and *org-graph-db* (db-open-p *org-graph-db*))
      *org-graph-db*
      (progn
        (load-opts *org-graph-db*))))

(defun destroy-org-graph-db ()
  (unless (null *org-graph-db*)
    (destroy-db *org-graph-db*)
    (log:info! "destroyed org-graph-db" *org-graph-db-directory*))
  (when (probe-file *org-graph-db-directory*)
    (sb-ext:delete-directory *org-graph-db-directory* :recursive t)))

(defun og-get (key &optional (from "node"))
  (get-val *org-graph-db* key :cf from))

(defun og-files ())
