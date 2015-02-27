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

(defgeneric output (package output))
(defmethod output ((package compilation-package) output)
  (format (destination-stream package) (format-spec package) output))

(defgeneric newline (package))
(defmethod newline ((package compilation-package))
  (output package #\Newline))

(defgeneric indent (package))
(defmethod indent ((package compilation-package))
  (dotimes (i (compilation-unit-indentation-spaces)) (output package #\Space)))

(defgeneric newline-and-indent (package))
(defmethod newline-and-indent ((package compilation-package))
  (newline package)
  (indent package))

(defgeneric pspace (package))
(defmethod pspace ((package compilation-package))
  (output package #\Space))

(defgeneric start-block (package block-name))
(defmethod start-block ((package compilation-package) block-name)
  (output package "(")
  (output package block-name)
  (incf *indentation-level*))

(defgeneric end-block (package))
(defmethod  end-block ((package compilation-package))
  (output package ")")
  (decf *indentation-level*))

(defgeneric add-property-pair (package key value))
(defmethod  add-property-pair ((package compilation-package) key value)
  (output package (concatenate 'string " :" key " " value)))

(defgeneric add-property (package property))
(defmethod  add-property ((package compilation-package) property)
  (add-property-pair package property (gethash property (fields package))))

(defmethod print-object ((package compilation-package) stream)
  (format stream "#<compilation-package of \"~A\" with fields" (name package))
  (loop for key being the hash-key of (fields package) do
       (format stream " ~A" key))
  (format stream ">"))

(defgeneric compile-package (package))
(defmethod compile-package ((package compilation-package))
  (newline-and-indent package)
  (start-block package (name package))
  (loop for key in (field-names package) do
       (let ((value (gethash key (fields package))))
	 (when value ;; nil er ikke tillatt som verdi. Kun strenger
	   (newline-and-indent package)
	   (add-property-pair package key value))))
  (end-block package))

(defgeneric set-fields (package hash-table)
  (:documentation
   (concatenate 'string
		"Setter inn elementene i `hash-table' til feltene i `package'.\n"
		"Eventuelle felt i `hash-table' som allerede eksisterer vil bli overskrevet\n")))

(defmethod set-fields ((package compilation-package) hash-table)
  (loop for key being the hash-keys in hash-table do
       (setf (gethash key (fields package))
	     (gethash key hash-table))))


