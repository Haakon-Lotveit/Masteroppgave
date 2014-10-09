(quicklisp:quickload "cl-csv")
;; Vurder om disse bør være en glob
;; Akkurat nå er de en glob, det fungerer utmerket, og alt det der,
;; men det er litt sært å ha en glob i et OO system, og de er litt tabu.

(defvar *indentation-level* 0)
(defvar *spaces-per-indent* 4)

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
;(load 
