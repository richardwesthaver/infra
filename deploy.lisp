;;; deploy.lisp --- yeeting blobs across the yard

;;

;;; Code:
(in-package :infra)

(defvar *autogen-fasl*
  (or (probe-file ".stash/tmp/autogen.fasl")
      (and
       (ensure-directories-exist ".stash/tmp/")
       (compile-file "autogen" :output-file ".stash/tmp/autogen"))))

(load *autogen-fasl*)

(defvar *dist* (getprofile :dist))

(pkg:defpkg :infra/deploy
  (:use :cl :std :skel :packy :dat/json :std/thread :infra/autogen))

(in-package :infra/deploy)

(defparameter *task-pool* (make-task-pool))

(with-task-pool (tp *task-pool*)
  (designate-oracle tp (find-thread "control-thread"))
  (spawn-workers tp 4)
  (print tp)
  ;; (start-task-pool tp)
  (loop for x below (worker-count tp)
        collect (pop-worker tp)))
