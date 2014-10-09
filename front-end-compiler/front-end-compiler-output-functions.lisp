
(defgeneric output (package output))
(defmethod output ((package compilation-package) output)
  (format (destination-stream package) (format-spec package) output))

(defgeneric indentation-spaces ())
(defmethod indentation-spaces ()
  (* *indentation-level* *spaces-per-indent*))

(defgeneric newline (package))
(defmethod newline ((package compilation-package))
  (output package #\Newline))

(defgeneric indent (package))
(defmethod indent ((package compilation-package))
  (dotimes (i (indentation-spaces)) (output package #\Space)))

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
  (output package (concatenate 'string ":" key " " value)))

(defgeneric add-property (package property))
(defmethod  add-property ((package compilation-package) property)
  (add-property-pair package property (gethash property (fields package))))

(defmethod print-object ((package compilation-package) stream)
  (format stream "#<compilation-package of \"~A\" with fields" (name package))
  (loop for key being the hash-key of (fields package) do
       (format stream " ~A" key))
  (format stream ">"))
