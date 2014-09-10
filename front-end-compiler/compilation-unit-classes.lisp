(quicklisp:quickload "cl-csv")

;; Vurder om disse bør være en glob
;; Akkurat nå er de en glob, det fungerer utmerket, og alt det der,
;; men det er litt sært å ha en glob i et OO system, og de er litt tabu.

(defvar *indentation-level* 0)
(defvar *spaces-per-indent* 4)
  
(defclass compilation-package ()
  ((emit-function
    :reader emit-function
    :initform (error "No emitter function supplied to constructor")
    :initarg :emit-function)
   
   (name
    :reader name
    :initform (error "No name supplied to cunstructor. Compilation package needs a name")
    :initarg :name)
   
   (field-names
    :reader field-names
    :initform (error "No field names supplied to the constructor.")
    :initarg :field-names)

   (actual-fields
    :reader fields
    :initform (make-hash-table :test 'equal)
    :initarg :fields)))

(defgeneric indentation-spaces ())
(defmethod indentation-spaces ()
  (* *indentation-level* *spaces-per-indent*))

(defgeneric newline (package))
(defmethod newline ((package compilation-package))
  (funcall (emit-function package) #\Newline))

(defgeneric indent (package))
(defmethod indent ((package compilation-package))
  (dotimes (i (indentation-spaces)) (funcall (emit-function package) #\Space)))

(defgeneric newline-and-indent (package))
(defmethod newline-and-indent ((package compilation-package))
  (newline package)
  (indent package))

(defgeneric pspace (package))
(defmethod pspace ((package compilation-package))
  (funcall (emit-function package) #\Space))

(defgeneric emit (package item))
(defmethod emit ((package compilation-package) item)
  (funcall (emit-function package) item))

(defgeneric start-block (package block-name))
(defmethod start-block ((package compilation-package) block-name)
  (funcall (emit-function package) "(")
  (funcall (emit-function package) block-name)
  (incf *indentation-level*))

(defgeneric end-block (package))
(defmethod  end-block ((package compilation-package))
  (funcall (emit-function package) ")")
  (decf *indentation-level*))

(defgeneric add-property-pair (package key value))
(defmethod  add-property-pair ((package compilation-package) key value)
  (funcall (emit-function package) (concatenate 'string " :" key " " value)))

(defgeneric add-property (package property))
(defmethod  add-property ((package compilation-package) property)
  (add-property-pair package property (gethash property (fields package))))

(defclass image-compilation-package (compilation-package)
  ((name :initform "image")))

(defclass table-compilation-package (compilation-package)
  ((name :initform "table")))

(defun make-table-cp (set-fields emit-function)
  (make-instance 'table-compilation-package
		 :field-names '("fil" "første-linje-er-tabellnavn")
		 :fields set-fields
		 :emit-function emit-function))

(defun make-image-cp (set-fields emit-function)
  (make-instance 'image-compilation-package
		 :field-names '("fil" "location" "size")
		 :fields set-fields
		 :emit-function emit-function))

(defmethod print-object ((package compilation-package) stream)
  (format stream "#<compilation-package of \"~A\" with fields" (name package))
  (loop for key being the hash-key of (fields package) do
       (format stream " ~A" key))
  (format stream ">"))

(defgeneric compile-package (package))
(defmethod compile-package ((package compilation-package))
  (start-block package (name package))
  (loop for key in (field-names package) do
       (let ((value (gethash key (fields package))))
	 (if value
	     (add-property-pair package key value)))
       (end-block package)
       (newline package)))

(defmethod compile-package ((package table-compilation-package))
  (indent package)
  (start-block package (name package))
  (let ((print-headers (string= "ja"
				(gethash "første-linje-er-tabellnavn" (fields package)))))
    (loop for row in (with-open-file (csv-stream (gethash "fil" (fields package)) :direction :input)
		       (cl-csv:read-csv csv-stream)) do
	 (newline package)
	 (indent package)
	 (start-block package "row")
	 (loop for cell in row do
	      (pspace package)
	      (if print-headers
		  (start-block package "header")
		  (start-block package "data"))
	      (pspace package)
	      (emit package (prin1-to-string cell))
	      (end-block package))
	 (setq print-headers nil)
	 (end-block package))
    (end-block package)
    (newline package)))

(defvar *image-hashmap* (progn
			  (let ((table (make-hash-table :test 'equal)))
			    (setf (gethash "fil" table) "~/Bilder/bilde.png")
			    (setf (gethash "location" table) "centered")
			    (setf (gethash "size" table) "50%")
			    table)))
(defvar *table-hashmap*
  (progn
    (let ((map (make-hash-table :test 'equal)))
      (setf (gethash "fil" map)
	    "exampledata/small-table.csv")
      (setf (gethash "første-linje-er-tabellnavn" map)
	    "ja")
      map)))

;; skal beholdes som en standard-formatterer, evt. en lambda som produserer denne funksjonen.
(defun std-emit (item)
  (format 'T "~A" item))
