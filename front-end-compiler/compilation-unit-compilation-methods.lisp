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

(defmethod compile-package ((package table-compilation-package))
  (newline-and-indent package)
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
	      (output package (prin1-to-string cell))
	      (end-block package))
	 (setq print-headers nil)
	 (end-block package))
    (end-block package)))

(defmethod compile-package ((package start-document))
  (newline-and-indent package)
  (start-block package "dokument"))

  
(defvar *image-hashmap*
  (progn
    (let ((table (make-hash-table :test 'equal)))
      (setf (gethash "fil"      table) "~/Bilder/bilde.png")
      (setf (gethash "location" table) "centered")
      (setf (gethash "size"     table) "50%")
      table)))

(defvar *table-hashmap*
  (progn
    (let ((map (make-hash-table :test 'equal)))
      (setf (gethash "fil" map)
	    "exampledata/small-table.csv")
      (setf (gethash "første-linje-er-tabellnavn" map)
	    "ja")
      map)))

