(print "This is not a proper parser. Do not think of this as parsing anything.")

(defvar *current-document* nil
  "The head document we're parsing")

(defun load-file (file-path)
  (with-open-file (file file-path :direction :input)
    (setf *current-document* (read file))))

(defun latex-compute-dependencies (document)
  "This is supposed to calculate what dependencies we currently have."
  ())

(defvar *latex-conf*
  '((documentclass ("11pr" "article"))
    (package ("hyperref"))
    (package ("T1" "fontenc"))
    (package ("utf8" "inputenc"))))

(defun make-prelude (conf)
  (loop for spec in conf do
             ;; If it's a documentclass thing
       (cond ((eq (car spec) 'documentclass)
	      (format 't "\\documentclass[~A]{~A}~%" "str" "typ"))
	     ;; If we want to use a package.
	     ((eq (car spec) 'package)
	      (cond ((= 1 (length (cadr spec)))
		     (format 't "\\usepackage{~A}~%" (caadr spec)))
		    ((= 2 (length (cadr spec)))
		     (format 't "\\usepackage[~A]{~A}~%"
			     (caadr spec)
			     (cadadr spec)))
		    ('DEFAULT (print "Error, only 1 or 2 args allowed for usepackage"))))
	     ('DEFAULT (print "Error, unknown token type")))))

(defun print-latex ()
  (let ((dependency-list (latex-compute-dependencies *current-document*))
	(config-list (load-conf *conf-file*)
    (
		 
    

(load-file "smallest-tree.lisp")

