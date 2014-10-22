(quicklisp:quickload "cl-csv")
(defvar *indentation-level* 0)
(defvar *spaces-per-indent* 4)

(defun indentation-spaces ()
  (* *indentation-level* *spaces-per-indent*))

(defun generate-load (filename)
  (load (merge-pathnames (format nil "front-end-compiler/~A.lisp" filename)
			 *default-pathname-defaults*)))

;; Dette er den mest grunnleggende klassen som alle andre pakker arver fra.
;; Inneholder også generics og standardmetoder for klassen, inkludert output og slikt.
(generate-load "basic-compilation-class")


;; Etter opprydning ellers her, kan det tenkes at dette nesten går tilbake til parseren?
(generate-load "start-document")
(generate-load "markdown-package")
(generate-load "image-compilation-package")
(generate-load "table-compilation-package")
(generate-load "text-compilation-package")
(generate-load "dokument-compilation-package")
(generate-load "preludium-compilation-package")
(generate-load "no-markup-text-passage")
(generate-load "directly-inserted-text-package")

(defmethod compile-package ((package dokument-compilation-package))
  package)

(defmethod compile-package ((package preludium-compilation-package))
  package)

(defmethod compile-package ((package text-compilation-package))
  (error "No compilation method have been defined for basic text-compilation"))

;; TODO: Bruk aux-metoden istedenfor
(defvar *image-hashmap* (progn
			  (let ((table (make-hash-table :test 'equal)))
			    (setf (gethash "fil" table) "~/Bilder/bilde.png")
			    (setf (gethash "location" table) "centered")
			    (setf (gethash "size" table) "50%")
			    table)))

;; TODO: Bruk aux-metoden istedenfor
(defvar *table-hashmap*
  (progn
    (let ((map (make-hash-table :test 'equal)))
      (setf (gethash "fil" map)
	    "exampledata/small-table.csv")
      (setf (gethash "første-linje-er-tabellnavn" map)
	    "ja")
      map)))

