(defclass no-markup-text-package (text-compilation-package)
  ((name
    :initform "no-markup-text")
   (field-names
    :initform '("text"))
   (text-type
    :initform "no-markup")))

(defmethod compile-package ((package no-markup-text-package))
  (newline-and-indent package)
  (start-block package (name package))
  (loop for line in (gethash "text" (fields package)) do
       (newline-and-indent package)
       (output package (prin1-to-string line)))
  (end-block package))
(let* ((*indentation-level* 0)
       (result (make-growable-string))
       (expected-value (concatenate 'String
				    +nl+ "(no-markup-text"
				    +nl+ "    \"This is not The Greatest Song in the World, no.\""
				    +nl+ "    \"This is just a tribute.\""
				    +nl+ "    \"Couldn't remember The Greatest Song in the World, no, no.\""
				    +nl+ "    \"This is a tribute, oh, to The Greatest Song in the World,\""
				    +nl+ "    \"All right! It was The Greatest Song in the World,\""
				    +nl+ "    \"All right! It was the best muthafuckin' song the greatest song in the world.\")"))

       (test (make-instance 'no-markup-text-package
			    :fields (make-hash-table-from-list '(("text" ("This is not The Greatest Song in the World, no."
									  "This is just a tribute."
									  "Couldn't remember The Greatest Song in the World, no, no."
									  "This is a tribute, oh, to The Greatest Song in the World,"
									  "All right! It was The Greatest Song in the World,"
									  "All right! It was the best muthafuckin' song the greatest song in the world.")))))))

  (with-output-to-string (string-stream result)
    (setf (destination-stream test) string-stream)
    (compile-package test))
  (test #'string= expected-value result "Test for compile-package method on type no-markup-text-package"))





			   
