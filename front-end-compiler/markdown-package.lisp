(defclass markdown-package (text-compilation-package)
  ((name
    :initform "markdown")
   (text-type
    :initform "markdown-standard")
   (field-names
    :initform '("input-text"))))


(defmethod compile-package ((package markdown-package))
  (newline-and-indent package)
  (output package (compile-markdown-string (get-text package))))
