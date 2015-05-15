(defclass text-compilation-package (compilation-package)
  ((name :initform (error "text-compilation-package has not overridden the name-field"))
   (text-type
    :reader text-type
    :initform (error "No text-type given to constructor. This must be set by overriding class")
    :initarg :text-type)))

(defgeneric get-text (package)
  (:documentation "Returns the text that this package knows about. If it has both \"sitat\" and \"fil\", then the \"sitat\" will be listed first."))

(defmethod get-text ((package text-compilation-package))
  (let ((fil   (gethash "fil"   (fields package)))
	(sitat (gethash "sitat" (fields package)))
	(string-stream (make-string-output-stream)))
    (if sitat (format string-stream "~A" sitat))
    (if fil   (format string-stream "~A"
		      (slurp-file fil)))
	
    (get-output-stream-string string-s
tream)))

