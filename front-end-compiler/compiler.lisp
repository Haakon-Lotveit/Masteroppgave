;;; Front end compiler for the project
;;; Currently everything here is a sketch, and nothing is final.
;;; Everything that works is being moved over to compilation-unit-classes.lisp for Object Orientation

;;; There are four main things that have to be defined here:
;;;  - How to insert text (plain, markdown, unescaped(, others?))
;;;  - How to insert tables (two dimensional ones, from CSV only) (kind of done)
;;;  - How to insert images (kind of done)
;;;  - How to run an external program
;;;  - How to define things in the preludium is not in this sprint at all.

;;; In addition to this, an abstraction facility must be made available to let
;;; the users create their own rules that extend on the above four things.

(defvar *stack* nil)
(defvar *gyldige-rapportbit-navn* (make-hash-table :test 'equal))

(defun reset-gyldige-rapportbit-navn-tabell (emit-function)
  (let ((table (make-hash-table :test 'equal)))
    (setf (gethash "Preludium:" table)
	  (lambda ()
	    (make-instance 'preludium-compilation-package
			   :field-names 'nil
			   :emit-function emit-function)))
    (setf (gethash "Dokument:" table)
	  (lambda ()
	    (make-instance 'dokument-compilation-package
			   :field-names 'nil
			   :emit-function emit-function)))
    (setf (gethash "Tabell:" table)
	  (lambda ()
	    (make-instance 'table-compilation-package
			   :field-names '("fil" "første-linje-er-tabellnavn")
			   :emit-function emit-function)))
    (setf (gethash "Tekst:" table)
	  (lambda ()
	    (make-instance 'text-compilation-package
			   :field-names 'nil
			   :emit-function emit-function)))
    (setf (gethash "Bilde:" table)
	  (lambda ()
	    (make-instance 'image-compilation-package
			   :field-names '("fil" "location" "size")
			   :emit-function emit-function)))
    (setf *gyldige-rapportbit-navn* table)))
    
(reset-gyldige-rapportbit-navn-tabell #'std-emit)

(defun er-ny-rapportbit-p (token)
  (if (gethash token *gyldige-rapportbit-navn*)
      T
      NIL))

(defun test-er-ny-rapportbit-p ()
  (flet ((og (v h) (and v h)))
    (and
     (reduce #'og (mapcar #'er-ny-rapportbit-p
			  '("Preludium:" "Dokument:" "Tabell:" "Tekst:" "Bilde:")))
     (not
      (reduce #'og (mapcar #'er-ny-rapportbit-p
			   '("Finnes ikke" "Preludium")))))))
(defun load-settings (settings-file)
  (null settings-file)
  (error "load-settings is not implemented"))

(defvar *testing-tokenlist* '("Dokument:"
			      "Tabell:"
			      "fil=\"exampledata/small-table.csv\""
			      "første-linje-er-tabellnavn=\"ja\""
			      "."
			      "Bilde:"
			      "file=\"Mine Bilder/\\\"reapers\\\".png\""
			      "."
			      "."))

(defun lag-ny-rapportbit (token)
  (on-creation (funcall (gethash token *gyldige-rapportbit-navn*))))


(defun behandle-token (token stack)
  (behandle (car stack) token))

(defun compile-dokument (tokens)
  (setf *stack* nil)
  (setf *indentation-level* 0)
  ;; TODO: stack bør være en let her, men er en glob for nå.
  (loop for token in tokens do
       (if (er-ny-rapportbit-p token)
	   (push (lag-ny-rapportbit token) *stack*)
	   (behandle-token token *stack*))))



