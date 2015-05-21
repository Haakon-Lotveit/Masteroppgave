(defclass table-compilation-package (compilation-package)
  ((name :initform "TABLE")
   (field-names :initform '("fil" "første-linje-er-tabellnavn"))))

(defgeneric num-cols (package))
(defmethod num-cols ((package table-compilation-package))
  (with-open-file (fstream (gethash "fil" (fields package)) :direction :input)
    (length (cl-csv:read-csv-row fstream))))
(defgeneric headers (package))
(defmethod headers ((package table-compilation-package))
  (cond
    ((string= "ja" (gethash "første-linje-er-tabellnavn" (fields package)))
    "yes")
    ('OTHERWISE
     "no")))

(defmethod compile-package ((package table-compilation-package))
  (newline-and-indent package)
  (start-block package (name package))
  (output package (format 'nil " :SIZE \"~A\" :HEADERS \"~A\"" 
			  (num-cols package)
			  (headers package)))
  (let ((print-headers (string= "ja"
  				(gethash "første-linje-er-tabellnavn" (fields package)))))
    (loop for row in (with-open-file (csv-stream (gethash "fil" (fields package)) :direction :input)
  		       (cl-csv:read-csv csv-stream)) do
	 (newline-and-indent package)
  	 (start-block package "ROW")
  	 (loop for cell in row do
  	      (pspace package)
  	      (if print-headers
  		  (start-block package "HEADER")
  		  (start-block package "DATA"))
  	      (pspace package)
  	      (output package  cell)
  	      (end-block package))
  	 (setq print-headers nil)
  	 (end-block package))
    (end-block package) 
))

