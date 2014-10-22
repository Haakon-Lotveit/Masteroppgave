(defclass table-compilation-package (compilation-package)
  ((name :initform "tabell")
   (field-names :initform '("fil" "første-linje-er-tabellnavn"))))


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
  	      (output package (prin1-to-string cell))
  	      (end-block package))
  	 (setq print-headers nil)
  	 (end-block package))
    (end-block package)))

