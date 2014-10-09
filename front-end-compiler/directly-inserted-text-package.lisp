(defclass directly-inserted-text-package (text-compilation-package)
  ((name
    :initform "directly-inserted-text")
   (field-names
    :initform '("text"))
   (text-type
    :initform "directly-inserted")))

(defmethod compile-package ((package directly-inserted-text-package))
  (newline-and-indent package)
  (start-block package (name package))
  (newline-and-indent package)
  (output package (prin1-to-string (gethash "text" (fields package))))
  (end-block package))
(let ((test (make-instance 'directly-inserted-text-package
			   :fields (make-hash-table-from-list '(("text" "This is the story of a girl etc.")))))
      (*indentation-level* 0)
      (result (make-growable-string))
      (expected-value (concatenate 'String
				   +nl+ "(directly-inserted-text"
				   +nl+ "    \"This is the story of a girl etc.\")")))
  (with-output-to-string (string-stream result)
    (setf (destination-stream test) string-stream)
    (compile-package test))
  (test #'string= expected-value result "Test for compile-package method on type no-markup-text-package"))

