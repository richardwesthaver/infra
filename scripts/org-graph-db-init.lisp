;;; org-graph-db-init.lisp --- Initialize the org-graph-db-directory

;; 

;;; Code:
#-user (ql:quickload :user)
(in-package :user)
(unless (find-package :org-graph-db)
  (pkg:defpkg :org-graph-db
    (:use :cl :std :rdb :cli :seq
     :db :query :id :uuid :q :schema)))

(in-package :org-graph-db)

(load-database-backend :rdb)

(deftype org-id () `(octet-vector 16))

(defclass org-graph-schema (rdb-schema) ()
  (:default-initargs
   :fields (make-fields :file '(pathname . octet-vector)
                        :title '(org-id . string)
                        :hash '(org-id . string)
                        :atime '(org-id . octet-vector)
                        :mtime '(org-id . octet-vector)
                        :node '(org-id . octet-vector)
                        :edge '(org-id . octet-vector)
                        :node-tags '(org-id . string)
                        :node-links '(org-id . string)
                        :node-properties '(org-id . string)
                        :node-priority '(org-id . string)
                        :node-schedule '(org-id . string)
                        :node-file '(org-id . string)
                        :node-pos '(org-id . octet-vector)
                        :node-state '(org-id . string))))

(defparameter *org-graph-schema* (make-instance 'org-graph-schema))

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
  (maphash (lambda (k v) (insert-key *org-graph-db* k
                                     (apply 'concatenate 'string v)
                                     :column "file"))
           *org-graph-id-locations*))

(defun insert-org-nodes ()
  (log:info! "inserting org nodes")
  (dolist (v (hash-table-values *org-graph-id-locations*))
    (dolist (id v)
      (insert-key *org-graph-db*
                  (handler-case (uuid-to-octet-vector (obj/uuid:make-uuid-from-string id))
                    (simple-error () id))
                  ;; TODO 2024-12-30: 
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
  (with-db (db :open (not (db-open-p *org-graph-db*)) :close nil :db *org-graph-db*)
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
        (load-opts *org-graph-db*)
        (open-columns* *org-graph-db*))))

(defun destroy-org-graph-db ()
  (unless (db-closed-p *org-graph-db*)
    (shutdown-db *org-graph-db*)
    (destroy-db *org-graph-db*)
    (log:info! "destroyed org-graph-db at ~A" *org-graph-db-directory*)))

(defun og-get (key &optional (from "node"))
  (get-val *org-graph-db* key :data-type 'string :column from))

(defun org-graph-values (column)
  (with-iter (it (iter *org-graph-db* :column (find-column column *org-graph-db*)))
    (seek-to-first)
    (loop while (iter-valid-p)
          if (equal column :file)
          collect (cons (pathname (sb-ext:octets-to-string (key)))
                        (let ((v (sb-ext:octets-to-string (val)))
                              (x 36)
                              (i 0))
                          (loop while (< i (length v))
                                collect (ignore-errors (uuid:make-uuid-from-string (subseq v i (incf i x)))))))
          else
          collect (cons (handler-case (octet-vector-to-uuid (key))
                          (simple-type-error () (sb-ext:octets-to-string (key))))
                        (sb-ext:octets-to-string (val)))
          do (next))))

(defun org-graph-file-scrape (path &rest ids)
  "Return a list of org headings corresponding to IDS in PATH."
  ;; first get an org-document and list of headings
  (let* ((doc (organ:org-parse :document path))
         (headings (organ:doc-tree doc))
         (ret))
    ;; map over IDs, searching for matches
    (loop for h across headings
          if (typep h 'organ:org-heading)
          do
          (push
           (when-let* ((prop (organ::org-properties h))
                       (id (find (print (value (find "ID" (print (organ:org-contents prop))
                                                     :key (lambda (x) (string-upcase (name x))))))
                                 ids
                                 :test 'equal)))
             (removef ids id :test 'equal)
             h)
           ret)
          finally (return ret))))

