(quicklisp:quickload "cl-csv")
(defvar *indentation-level* 0)
(defvar *spaces-per-indent* 4)

(defun indentation-spaces ()
  (* *indentation-level* *spaces-per-indent*))

;; skal beholdes som en standard-formatterer, evt. en lambda som produserer denne funksjonen.
(defun std-emit (item)
  (format 'T "~A" item))

(defclass compilation-package ()
  ((output-format-spec
    :reader format-spec
    :initform "~A"
    :initarg :output-format-spec)

   (destination-stream
    :accessor destination-stream
    :initform *standard-output*
    :initarg :destination-stream)
   
   (name
    :accessor name
    :initform (error "No name supplied to constructor. Compilation package needs a name")
    :initarg :name)
   
   (field-names
    :reader field-names
    :initform (error "No field names supplied to the constructor.")
    :initarg :field-names)

   (actual-fields
    :reader fields
    :initform (make-hash-table :test 'equal)
    :initarg :fields)))

(defclass start-document (compilation-package)
  ((name :initform "start-of-document")
   (field-names :initform '())))

(defclass text-compilation-package (compilation-package)
  ((name :initform (error "text-compilation-package has not overridden the name-field"))
   (text-type
    :reader text-type
    :initform (error "No text-type given to constructor. This should be set by overriding class")
    :initarg :text-type)))

(defclass no-markup-text-package (text-compilation-package)
  ((name
    :initform "no-markup-text")
   (text-type
    :initform "no-markup")))

(defclass directly-inserted-text-package (text-compilation-package)
  ((name
    :initform "directly-inserted-text")
   (text-type
    :initform "directly-inserted")))

(defclass markdown-package (text-compilation-package)
  ((name
    :initform "markdown")
   (text-type
    :initform "markdown-standard")))

(defclass image-compilation-package (compilation-package)
  ((name :initform "bilde")
   (field-names :initform '("fil" "plassering" "størrelse"))))

(defclass table-compilation-package (compilation-package)
  ((name :initform "tabell")
   (field-names :initform '("fil" "første-linje-er-tabellnavn"))))

;; Laster inn relevante generiske funksjoner/metodespesialiseringer til kompileringsklassene,
;; for å unngå at alt er i en massiv fil.
;; TODO: arranger om til å heller laste inn per klasse.
(load "front-end-compiler-output-functions.lisp")
(load "compilation-unit-compilation-methods.lisp")


;; Framtiden så langt: Last per subklasse
(load "no-markup-text-passage.lisp")
(load "directly-inserted-text-package.lisp")

;; DETTE SKAL EGENTLIG VEKK. TODO, ETC.
(defclass text-compilation-package (compilation-package)
  ((name :initform "text")))

(defclass image-compilation-package (compilation-package)
  ((name :initform "image")))

(defclass table-compilation-package (compilation-package)
  ((name :initform "table")))

(defclass dokument-compilation-package (compilation-package)
  ((name :initform "dokument")))

(defclass preludium-compilation-package (compilation-package)
  ((name :initform "preludium")))

(defgeneric set-fields (package hash-table)
  (:documentation
  (concatenate 'string
   "Setter inn elementene i `hash-table' til feltene i `package'.\n"
   "Eventuelle felt i `hash-table' som allerede eksisterer vil bli overskrevet\n")))

(defmethod set-fields ((package compilation-package) hash-table)
  (loop for key being the hash-keys in hash-table do
       (setf (gethash key (fields package))
	     (gethash key hash-table))))

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

(defmethod print-object ((package dokument-compilation-package) stream)
  (format stream "#<dokument-compilation-package>"))

(defmethod print-object ((package compilation-package) stream)
  (format stream "#<compilation-package of \"~A\" with fields" (name package))
  (loop for key being the hash-key of (fields package) do
       (format stream " ~A" key))
  (format stream ">"))

(defgeneric behandle (compilation-unit token)
  (:documentation "Tar en token, og gjør hva som gjerast skal med den"))

(defmethod behandle ((compilation-unit compilation-package) (token string))
  (flet ((token-is (string) (string= token string)))
    (cond ((token-is ".")
	   (progn
	     (pop *stack*)
	     (compile-package compilation-unit)
	     (when-done compilation-unit)))
	  
	  ('Standard-prosedyre-om-intet-annet-passer
	   (let ((key (subseq token 0 (position #\= token)))
		 (val (subseq token (1+ (position #\= token)))))
	     (setf (gethash key (fields compilation-unit)) (read-from-string val))))))
  compilation-unit)

(defgeneric on-creation (package))
(defmethod on-creation ((package compilation-package)) package)
(defmethod on-creation ((package dokument-compilation-package))
  (start-block package "dokument")
  package)

(defgeneric when-done (package))
(defmethod when-done ((package compilation-package)) package)
(defmethod when-done ((package dokument-compilation-package))
  (end-block package))

(defgeneric compile-package (package))

(defmethod compile-package ((package compilation-package))
  (error (format nil "Ingen overkjørt metode for \"~A\"" package)))

(defmethod compile-package ((package dokument-compilation-package))
  package)

(defmethod compile-package ((package preludium-compilation-package))
  package)

(defmethod compile-package ((package image-compilation-package))
  (newline-and-indent package)
  (start-block package (name package))
  (loop for key being the hash-keys of (fields package) do
       (add-property package key))
  (end-block package))

(defmethod compile-package ((package text-compilation-package))
  (error "No compilation method have been defined for text-compilation"))

(defmethod compile-package ((package table-compilation-package))
  (newline-and-indent package)
  (start-block package (name package))
  (let ((print-headers (string= "ja"
  				(gethash "første-linje-er-tabellnavn" (fields package)))))
    (loop for row in (with-open-file (csv-stream (gethash "fil" (fields package)) :direction :input)
  		       (cl-csv:read-csv csv-stream)) do
	 (newline-and-indent package)
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
    (end-block package)))

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

